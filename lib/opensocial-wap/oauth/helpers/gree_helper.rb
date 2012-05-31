# -*- coding: utf-8 -*-
module OpensocialWap::OAuth::Helpers

  # gree 用 oauthヘルパー.

  class GreeHelper < BasicHelper

        def verify(options = nil)
          request_proxy = self.class.proxy_class.new(@request)

          opts = {
            :consumer_secret => self.class.consumer_secret,
            :token_secret => request_proxy.parameters['oauth_token_secret'] }
          @access_token = ::OAuth::AccessToken.new(consumer,
                                                   request_proxy.parameters['oauth_token'],
                                                   request_proxy.parameters['oauth_token_secret'])
          signature = ::OAuth::Signature.build(request_proxy, opts)
          p signature.verify
            p "oauth signature : #{::OAuth::Signature.sign(request_proxy, opts)}"
            p "=== OauthHandler OAuth verification: ==="
            p "  authorization header: #{@request.env['HTTP_AUTHORIZATION']}"
            p "  base string:          #{signature.signature_base_string}"
            p "  signature:            #{signature.signature}"      

          if logger = @request.logger
            logger.debug "oauth signature : #{::OAuth::Signature.sign(request_proxy, opts)}"
            logger.debug "=== OauthHandler OAuth verification: ==="
            logger.debug "  authorization header: #{@request.env['HTTP_AUTHORIZATION']}"
            logger.debug "  base string:          #{signature.signature_base_string}"
            logger.debug "  signature:            #{signature.signature}"      
          end

          signature.verify
        rescue Exception => e
          false
        end        

        def consumer 
          @consumer ||= ::OAuth::Consumer.new(self.class.consumer_key, self.class.consumer_secret)
        end


    def authorization_header(api_request, options = nil)
          opts = { :consumer => consumer }
          opts[:token] = access_token if access_token
          if @request
            opts[:xoauth_requestor_id] = @request.params['opensocial_viewer_id'] || @request.params['opensocial_owner_id']
          end
          oauth_client_helper = ::OAuth::Client::Helper.new(api_request, opts.merge(options))
          oauth_client_helper.header
    end
  end
end
