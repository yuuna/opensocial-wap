# -*- coding: utf-8 -*-
require 'opensocial-wap/oauth/request_proxy/oauth_rack_request_proxy'

# signature_base_string の構築に、POSTパラメータを含めないプラットフォーム用の request proxy.
module OpensocialWap::OAuth::RequestProxy
  class OAuthRackRequestProxyForGree < OAuthRackRequestProxy

    def parse_params params_str
      if params_str && params_str.size > 0
        params_str.split('&').inject({}) do |hsh, i|
          kv = i.split('=')
          key = ::Rack::Utils::unescape(kv[0])
          v = kv[1] ? ::Rack::Utils::unescape(kv[1]) : ''
          v = v.to_i.to_s == v ? v.to_i : v       # GREEでは、数値的にソートされてnormalizeされてしまうので、その対応
          if hsh[key]
            hsh[key] << v
          else
            hsh[key] = [ v ]
          end
          hsh
        end
      else
        {}
      end
    end

  end
end
