module AudioAddict
  class CLI
    def self.router
      router = MisterBin::Runner.new version: VERSION,
        header: "AudioAddict Radio Utilities"

      router.route 'login',    to: Commands::LoginCmd
      router.route 'status',   to: Commands::StatusCmd
      router.route 'network',  to: Commands::NetworkCmd
      router.route 'channel',  to: Commands::ChannelCmd
      router.route 'channels', to: Commands::ChannelsCmd
      router.route 'now',      to: Commands::NowCmd
      router.route 'vote',     to: Commands::VoteCmd
      router.route 'playlist', to: Commands::PlaylistCmd

      router
    end
  end

end
