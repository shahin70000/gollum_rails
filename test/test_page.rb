require File.expand_path(File.join(File.dirname(__FILE__), "helper"))

context "Page Test" do
  include Rack::Test::Methods
  setup do
    @commit = {
      :message => "test creation of page",
      :name => 'Florian Kasper',
      :email => 'nirnanaaa@khnetworks.com'
    }
    attributes = {
      :name => 'TestPage',
      :content => 'content',
      :format => :markdown,
      :commit => @commit
    }
    @page = GollumRails::Page.new(attributes)
  end
  test "#tests the creation of the page" do
    assert_equal false, @page.persisted?
  end
  test "#tests the valid?`function" do
    assert_equal true, @page.valid?
    @page.name = nil
    assert_equal false, @page.valid?
    @page.name = 'TestPage'
    @page.format = nil
    assert_equal false, @page.valid?
    @page.format = :markdown
    @page.commit = false
    assert_equal false, @page.valid?
    @page.commit = @commit
  end
  test "#is the wiki an instance of gollum?" do
    assert_equal true, @page.wiki_loaded?(@page.wiki.wiki)
    assert_instance_of Gollum::Wiki, @page.wiki.wiki
    assert_instance_of GollumRails::Wiki, @page.wiki
  end
  test "#save" do
    name =  Time.now.to_s
    @page.name = name

    #first run should pass
    assert_equal true, @page.save

    #page already exist
    assert_equal false, @page.save
    
    f = @page.find(name)
    assert_instance_of String, @page.delete(@commit)
    
  end

  test "#get error message" do
    @page.name = "static"
    @page.save
    assert_instance_of Gollum::DuplicatePageError, @page.get_error_message
  end
  test "#find page" do
    found = @page.find("static")
    assert_instance_of Gollum::Page, found
    assert_equal 'content', found.raw_data
    assert_equal :markdown, found.format
    assert_equal '<p>content</p>', found.formatted_data
    assert_equal nil, @page.get_error_message

  end
  test "#nil provided" do
    found_not = @page.find(nil) #same as @page.find
    assert_equal nil, found_not
  end
  test "#page not found" do
    found_not = @page.find("i am not existant or am i")
    assert_equal nil, found_not
    assert_equal "The page was not found" ,@page.get_error_message
  end
  test "#page update" do
    origin = @page.find("static")
    assert_instance_of String, @page.update("content", @commit)
  end
  #test "#method_missing" do
  #  found = @page.find_by_id
  #  assert_instance_of Gollum::Page, found
  #end

  test "#production test runs (create|update|delete)" do
    wiki = GollumRails::Wiki.new(PATH)
    page = GollumRails::Page.new
    cnt = page.find("static")
    commit = {
      :message => "production test update",
      :name => 'Florian Kasper',
      :email => 'nirnanaaa@khnetworks.com'
    }
    update = page.update("content", commit)
    assert_instance_of String, update

    commit[:message] = "test delete"
    delete = page.delete(commit)
    assert_instance_of String, delete

    commit[:message] = "test create"
    page = GollumRails::Page.new({
      :name => 'static',
      :content => 'content',
      :format => :markdown,
      :commit => commit
    })
    assert_equal true, page.save
  end

  ### RAILS MODEL
  class Page < GollumRails::Page
  end

  ###/RAILS MODEL

  test "#rails model test" do
    ## Controller
    commit = {
      :message => "rails test",
      :name => 'Florian Kasper',
      :email => 'nirnanaaa@khnetworks.com'
    }

    time = Time.now.to_s
    page = Page.new({
      :name => "static-#{time}",
      :content => 'content',
      :format => :markdown,
      :commit => commit
    })
    save = page.save!
    assert_equal true, save
    if save
      puts "\nstatic-#{time} saved"
    end

    found = page.find "static-#{time}"

    assert_instance_of Gollum::Page, found

    if page.delete! commit
      puts "static-#{time} deleted"
    end

  end
  test "#attr setter" do
    page = Page.new

    page.name = "testpage"
    page.content = "content"
    page.format = :markdown

    page.commit = {
      :message => "rails test",
      :name => 'Florian Kasper',
      :email => 'nirnanaaa@khnetworks.com'
    }
    assert_equal "testpage", page.name

    #must differ in message
    assert_not_equal @commit, page.commit
    assert_equal "content", page.content
    assert_equal :markdown, page.format
    assert_instance_of Hash, page.commit
  end
  test "#static calls" do
    puts GollumRails::Page.find('static').nil?
    puts GollumRails::Page.get_error_message
  end

  test "#formats" do
    page = Page.new

    testformats = [:markdown, :creole, :asciidoc, :org, :pod, :rdoc, :rst, :textile, :wiki]
    testformats.each do |k,f|
      if !f.nil?

        page.commit = {
          :message => "test",
          :name => 'FlorianKasper',
          :email => 'nirnanaaa@khnetworks.com'
        }
        page.content = "accccccc"
        page.name = "asciidoc" + k
        page.format = f.parameterize.underscore.to_sym
        page.save!
        page.find(page.name)
        page.delete(commit)
      end

    end

  end
end
