require 'uri'
require 'MrMurano/Config'
require 'MrMurano/http'
require 'MrMurano/verbosing'
require 'MrMurano/SyncUpDown'

module MrMurano
  class SolutionBase
    def initialize
      if !defined?(@solntype) or @solntype.nil?
        @solntype = 'application.id'
      end
      # Get the application.id or product.id.
      @sid = $cfg[@solntype]
      # Maybe raise "No application!" or "No product!".
      raise MrMurano::ConfigError.new("No #{/(.*).id/.match(@solntype)[1]}!") if @sid.nil?
      @uriparts = [:solution, @sid]
      @itemkey = :id
      @project_section = nil
    end

    include Http
    include Verbose

    ## Generate an endpoint in Murano
    # Uses the uriparts and path
    # @param path String: any additional parts for the URI
    # @return URI: The full URI for this enpoint.
    def endPoint(path='')
      parts = ['https:/', $cfg['net.host'], 'api:1'] + @uriparts
      s = parts.map{|v| v.to_s}.join('/')
      URI(s + path.to_s)
    end
    # …

    def get(*args)
      ret = super
      if ret.nil?
        warning "No solution with ID: #{@sid}"
        exit 1
      end
      ret
    end

    include SyncUpDown
  end

  class Solution < SolutionBase
    def initialize
      # Code path for `murano domain`.
      @solntype = 'application.id'
      super
    end

    def version
      get('/version')
    end

    def info
      get()
    end

    def list
      get('/')
    end

    def usage
      get('/usage')
    end

    def log
      get('/logs')
    end

  end

end

#  vim: set ai et sw=2 ts=2 :
