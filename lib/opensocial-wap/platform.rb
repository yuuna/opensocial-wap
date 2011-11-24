module OpensocialWap
  module Platform
    # Singleton Pattern
    extend self

    def configure(config)
      @config = config
      @session = true
      @touch = false
    end

    def consumer_key(key)
      @consumer_key = key
    end

    def consumer_secret(secret)
      @consumer_secret = secret
    end

    def session(enabled = true)
      @session = enabled
    end

    def sandbox(sandbox = true)
      @sandbox = sandbox
    end

    def app_id(app_id)
      @app_id = app_id
    end

    def touch(enabled = false)
      @touch = enabled
    end
  end
end
