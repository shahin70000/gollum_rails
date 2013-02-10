module GollumRails
  module PageActions
    # Public: .create or .create! builtin extension for GollumRails::Page
    class Create < GollumRails::PageHelper
      # Public: Page.<call_by> . The method call will be generated with this information
      call_by 'create'
      call_by 'create!'
      class << self
        # Public: runs the initializer from superclass ( super clears the error buffer )
        #
        # Returns nothing
        def initialized_first
          super
        end

        # Public: performs upper methods in Page class
        #
        #
        # Examples
        #
        # Returns String
        def single_run(*argv)
          
        end
      end
    end
  end
end
