module DPL
  class Provider
    class CloudFoundry < Provider

      def initial_go_tools_install
        context.shell 'wget https://github.com/s-matyukevich/set-token/raw/master/out/cf'
        context.shell 'chmod +x cf'
        context.shell './cf install-plugin -f https://github.com/s-matyukevich/set-token/raw/master/out/set-token'
      end

      def check_auth
        initial_go_tools_install
        context.shell "./cf api #{option(:api)} #{'--skip-ssl-validation' if options[:skip_ssl_validation]}"
        context.shell "echo '#{options[:refresh_token]}'"
        context.shell "./cf set-token -a '#{options[:access_token]}' -r '#{options[:refresh_token]}' -c '#{options[:oauth_client]}' -s '#{options[:oauth_client_secret]}'"
        context.shell "CF_TRACE=true ./cf target -o #{option(:organization)} -s #{option(:space)}"
      end

      def check_app
        if options[:manifest]
          error 'Application must have a manifest.yml for unattended deployment' unless File.exists? options[:manifest]
        end
      end

      def needs_key?
        false
      end

      def push_app
        context.shell "./cf push#{manifest}"
        context.shell "./cf logout"
      end

      def cleanup
      end

      def uncleanup
      end

      def manifest
        options[:manifest].nil? ? "" : " -f #{options[:manifest]}"
      end
    end
  end
end
