module GollumRails

  # Main class, used to interact with rails.
  #
  # Methods, which are available:
  #   * find
  #   * update_attributes
  #   * find_by_*
  #   * create
  #   * new
  #   * save
  #   * delete
  #   * find_or_initialize_by_name
  #
  class Page
    include ::ActiveModel::Model

    include Callbacks
    include Core
    include Store
    include Validation
    include Persistance
    include Finders

    
    
    # Initializes a new Page
    #
    # attrs - Hash of attributes
    #
    # commit must be given to perform any page action!
    def initialize(attrs = {})
      run_callbacks :initialize do
        if Adapters::Gollum::Connector.enabled
          attrs.each{|k,v| self.public_send("#{k}=",v)} if attrs
          update_attrs if attrs[:gollum_page]
        else
          raise GollumInternalError, 'gollum_rails is not enabled!'
        end
      end
    end


    # Gets the pages format
    def format
      (@format || @gollum_page.format).to_sym
    end

    def name
      @name ||= @gollum_page.name
    end
    
    # == Outputs the pages filename on disc
    #
    # ext - Wether to output extension or not
    def filename(ext=true)
      @filename ||= (ext) ? @gollum_page.filename : @gollum_page.filename_stripped
    end
    
    def content
      @content ||= @gollum_page.content
    end

    # Gets the page class
    def page
      Adapters::Gollum::Page.new
    end




    

    
    # == Previews the page - Mostly used if you want to see what you do before saving
    #
    # This is an extremely fast method!
    # 1 rendering attempt take depending on the content about 0.001 (simple markdown)
    # upto 0.004 (1000 chars markdown) seconds, which is quite good
    #
    #
    # format - Specify the format you want to render with see {self.format_supported?}
    #          for formats
    #
    # Returns a String
    def preview(format=:markdown)
      page.preview_page( wiki, name, content, format )
    end

    # == Gets the url for current page from Gollum::Page
    #
    # Returns a String
    def url
      gollum_page.url_path
    end
    
    # == Gets the title for current Gollum::Page
    #
    # Returns a String
    def title
      gollum_page.title
    end
    
    # == Gets formatted_data for current Gollum::Page
    #
    # Returns a String
    def html_data
      gollum_page.formatted_data
    end
    
    
    # == Gets raw_data for current Gollum::Page
    #
    # Returns a String
    def raw_data
      gollum_page.raw_data
    end
    
    # == Gets the history of current gollum_page
    #
    # Returns an Array
    def history
      return nil unless persisted?
      gollum_page.versions
    end
    
    # == Gets the last modified by Gollum::Committer
    #
    # Returns a String
    def last_changed_by
      "%s <%s>" % [history.last.author.name, history.last.author.email]
    end
    
    # == Compare 2 Commits.
    #
    # sha1 - SHA1
    # sha2 - SHA1
    def compare_commits(sha1,sha2=nil)
      Page.wiki.full_reverse_diff_for(@gollum_page,sha1,sha2)
    end
    
    # == The pages filename, based on the name and the format
    # 
    # Returns a String
    # def filename
    #   Page.wiki.page_file_name(@name, @format)
    # end
      
    # == Checks if current page is a subpage
    def sub_page?
      return nil unless persisted?
      @gollum_page.sub_page
    end
    
    # == Gets the version of current commit
    #
    def current_version(long=false)
      return nil unless persisted?
      unless long
        @gollum_page.version_short 
      else
        @gollum_page.version.to_s
      end
      
    end
    
    #######
    private
    #######

    # == Gets the right commit out of 2 commits
    #
    # commit_local - local commit Hash
    #
    # Returns local_commit > class_commit
    def get_right_commit(commit_local)
      com = commit if commit_local.nil?
      com = commit_local if !commit_local.nil?
      return com
    end
    
    # == Updates local attributes from gollum_page class
    #
    def update_attrs
      @name = gollum_page.name
      @content= gollum_page.raw_data
      @format = gollum_page.format      
    end
    
    # == To static
    def wiki
      self.class.wiki
    end
    
  end
  
  if defined?(ActiveSupport)
    ActiveSupport.run_load_hooks(:gollum, Page)
  end
  
 end
