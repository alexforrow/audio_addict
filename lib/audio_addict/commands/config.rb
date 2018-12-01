module AudioAddict
  module Commands
    class ConfigCmd < Base
      summary "Manage local configuration"

      usage "radio config set KEY VALUE"
      usage "radio config get KEY"
      usage "radio config del KEY"
      usage "radio config show"
      usage "radio config edit"
      usage "radio config keys"
      usage "radio config --help"

      param "KEY", "Config key"
      param "VALUE", "Config value"

      option "-s --show", "Show the contents of the config file"
      option "-e --edit", "Open the config file for editing"

      command "get", "Show the value of this config key."
      command "set", "Set the value of this config key."
      command "del", "Delete the value of this config key."
      command "show", "Show the entire config file contents."
      command "edit", "Open the config file for editing."
      command "keys", "Show a list of supported config keys and their purpose."

      example "radio config edit"
      example "radio config set like_log ~/like.log"
      example "radio config del session_key"
      example "radio config get listen_key"

      def get_command(args)
        key = args['KEY'].to_sym
        value = Config.properties[key]
        say value ? "!txtgrn!#{value}" : "!txtred!<Unset>"
      end

      def set_command(args)
        key = args['KEY'].to_sym
        value = args['VALUE']
        Config.properties[key] = value
        Config.save
        say "!txtgrn!#{key}=#{value}"
      end

      def del_command(args)
        key = args['KEY'].to_sym
        Config.delete key
        Config.save
        say "!txtgrn!Deleted"
      end

      def show_command(args)
        say "!undpur!# #{Config.path}"
        if File.exist? Config.path
          puts File.read Config.path
        else
          say "!txtred!File Not Found"
        end
      end

      def edit_command(args)
        editor = ENV['EDITOR'] || 'vi'
        system "#{editor} #{Config.path}"
      end

      def keys_command(args)
        key_guide.each do |key, value|
          say "!txtgrn!#{key}"
          say word_wrap "  #{value}"
          say ""
        end
      end

    private

      def key_guide
        {
          session_key: "Used for authentication.\nUsually set with !txtpur!radio login!txtrst!.",
          listen_key: "Used for generating playlists.\nUsually set with !txtpur!radio login!txtrst!.",
          network: "Specify the AudioAddict network you are currently listening to.\nUsually set with !txtpur!radio set!txtrst!.",
          channel: "Specify the AudioAddict channel you are currently listening to.\nUsually set with !txtpur!radio set!txtrst!.",
          like_log: "Specify the path to store all your positive votes.\nIf this is not set, votes will only be sent to AudioAddict and not logged locally.",
          cache_dir: "Specify the path to store API response cache.\nDefault: ~/.audio_addict/cache",
          cache_life: "Specify the cache life period.\nDefault: 6h.",
        }
      end
      
    end
  end
end