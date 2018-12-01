module AudioAddict
  module Commands
    class SetCmd < Base
      summary "Set the radio network and channel"

      help "Save the channel and network to the config file for future use"

      usage "radio set [CHANNEL NETWORK]"
      usage "radio set --help"

      param "CHANNEL", "AudioAddict channel key. You can use a partial key here or leave empty for an interactive prompt."
      param "NETWORK", "AudioAddict network key. You can use a partial key here or leave empty for an interactive prompt."

      example "radio set"
      example "radio set punk"
      example "radio set dance digitally"
      example "radio set dance di"
      example "radio set metal rockradio"

      def run(args)
        channel = args['CHANNEL']
        network = args['NETWORK']

        full_set = (channel and network) || !(channel or network)

        if full_set
          set_both channel, network
        else
          set_channel channel
        end
      end

    private

      def set_both(channel, network)
        needs :session_key

        if !network or !Radio.valid_network? network
          network_menu network
        elsif Radio.valid_network? network
          save_network network
        end

        set_channel channel
      end

      def set_channel(channel)
        needs :network, :session_key

        if !channel
          channel_menu

        elsif radio.valid_channel? channel
          save_channel channel
        
        elsif radio.search(channel).any?
          channel_menu channel

        else
          say "!txtred!Invalid channel: #{radio.name} > #{channel}"

        end
      end

      def channel_menu(channel = nil)
        list = channel ? radio.search(channel).values : radio.channels.values

        if list.count == 1
          save_channel list.first.key
        else
          answer = channel_prompt list
          save_channel(answer, echo: false) unless answer == :cancel
        end
      end

      def network_menu(network = nil)
        list = Radio.networks network

        if list.count == 1
          save_network list.keys.first
        else
          answer = network_prompt list
          save_network(answer, echo: false) unless answer == :cancel
        end
      end

      def channel_prompt(channels)
        options = channels.map { |channel| ["#{channel.name.ljust 20} # #{channel.key}", channel.key] }.to_h
        options = { "Cancel" => :cancel }.merge options
        prompt.select "Channel :", options, marker: '>', filter: true
      end

      def network_prompt(networks)
        options = networks.invert
        options["Cancel"] = :cancel
        prompt.select "Network :", options, marker: '>', filter: true
      end

      def save_channel(channel, echo: true)
        Config.channel = channel
        Config.save
        say "Channel : !txtgrn!#{radio.name} > #{current_channel.name}!txtrst! # #{channel}" if echo
      end

      def save_network(network, echo: true)
        Config.network = network
        Config.save
        say "Network : !txtgrn!#{radio.name}!txtrst! # #{network}" if echo
      end

    end
  end
end