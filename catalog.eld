;; -*- lisp-data -*-

;; The catalog of the LispM Store: what LispM Desktop's App Store offers to
;; install, applications and extensions, and the roles and skills of LispM's
;; agents.  It is data, read and never evaluated; README.org describes its
;; format, and `make check' checks it.

(:name "LispM Store"
 :items
 (;; Applications.

  (elfeed
   :kind app
   :name "Elfeed"
   :subtitle "Web feeds"
   :category news
   :description "A reader of web feeds, RSS and Atom: blogs, news and podcasts, searched and tagged in Emacs."
   :icon "elfeed"
   ;; Release 4.2.1.
   :package (elfeed :url "https://github.com/skeeto/elfeed"
                    :rev "acbb86e342d2b8f85dfb30dce9df01db9a829c77")
   :command elfeed)

  (emms
   :kind app
   :name "EMMS"
   :subtitle "Music player"
   :category music
   :description "The Emacs Multimedia System: your Music library and folders of music, played through mpv or macOS's afplay, with playlists and a browser of your library."
   :icon "emms"
   :package emms
   :command emms-browser
   :needs ((program "mpv" :for "playing music" :brew "mpv"
                    :instead ("afplay") :more "seeking and radio streams")
           (program "exiftool" :for "reading the tags of AAC and Apple Lossless files" :brew "exiftool"
                    :instead ("mdls") :more "the tags Spotlight has not read")))

  (yeetube
   :kind app
   :name "Yeetube"
   :subtitle "YouTube videos"
   :category music
   :description "YouTube searched from Emacs, the videos listed with their channels and lengths, played through mpv, downloaded with yt-dlp, and saved for later."
   :icon "yeetube"
   ;; Release 2.3.1, whose tag is named 0.2.3.
   :package (yeetube :url "https://git.thanosapollo.org/yeetube"
                     :rev "4bbb5c37b77811b69b2d4483bdb7042247c587a1")
   :command yeetube-search
   ;; mpv plays YouTube's videos through yt-dlp.
   :needs ((program "mpv" :for "playing videos" :brew "mpv"
                    :commands (yeetube-play yeetube-replay yeetube-play-saved-video)
                    :variables (yeetube-mpv-program))
           (program "yt-dlp" :for "downloading videos, and playing them in mpv" :brew "yt-dlp"
                    :commands (yeetube-play yeetube-replay yeetube-play-saved-video
                               yeetube-download-video yeetube-download-videos)
                    :variables (yeetube-ytdlp-program))))

  (calculator
   :kind app
   :name "Calculator"
   :subtitle "Calc"
   :category utilities
   :description "Calc, Emacs's calculator: arbitrary precision, units, matrices, algebra and calculus, in reverse Polish or algebraic notation."
   :icon "calculator"
   :command calc)

  (calendar
   :kind app
   :name "Calendar"
   :subtitle "Months and the diary"
   :category productivity
   :description "Emacs's calendar: months at a glance, holidays, sunrise and sunset, phases of the moon, and the diary."
   :icon "calendar"
   :command calendar)

  (stickies
   :kind app
   :name "Stickies"
   :subtitle "Notes on the desktop"
   :category productivity
   :description "Mac OS 9's Stickies: notes in seven colours over the desktop, rolled up into their title bars, kept as headings of one org file that agents read too."
   :icon "stickies"
   :package (lispm-stickies :url "https://github.com/LispMachineLab/lispm-stickies"
                            :rev "822cc3fbcd5eeaca4c61a1cb058a48c6eacc38ca")
   :feature lispm-stickies)

  (security
   :kind app
   :name "Security"
   :subtitle "What agents run, checked"
   :category utilities
   :description "Checks what agents are given to run, the MCP servers and skills of LispM, Claude Code and Codex: their settings and text against rules, skills' code read as Lisp, servers' tools pinned, packages looked up in OSV."
   :icon "security"
   :package (lispm-security :url "https://github.com/LispMachineLab/lispm-security"
                            :rev "6486295285c68eca1a92306f03cc60203c2b5c24")
   :command lispm-security)

  (1password
   :kind app
   :name "1Password"
   :subtitle "Passwords and codes"
   :category utilities
   :description "The vaults of 1Password through op, its command-line tool: items searched as you type, usernames, passwords and one-time codes copied and cleared from the clipboard after 90 seconds, new logins with generated passwords. Secrets are read only when used, never kept nor written to disk."
   :icon "1password"
   :package (lispm-1password :url "https://github.com/LispMachineLab/lispm-1password"
                             :rev "a72c2f1b595c3035990cb60d0e35b8c450987973")
   :command lispm-1password
   :needs ((program "op" :for "reading your vaults" :cask "1password-cli")))

  ;; To chat with.

  (erc
   :kind app
   :name "ERC"
   :subtitle "IRC chat"
   :category social
   :description "ERC, Emacs's own IRC client: the networks you are on, Libera.Chat or another, each over its channels and the people talking with you, connected to again as it opens."
   :icon "erc"
   :command erc-tls)

  (slack
   :kind app
   :name "Slack"
   :subtitle "Workspaces and channels"
   :category social
   :description "emacs-slack: your Slack workspaces' channels and direct messages, signed in to with the token and cookie Slack's web app signs in with, which auth-source keeps."
   :icon "slack"
   ;; No releases; a commit of main that was read.
   :package (slack :url "https://github.com/emacs-slack/emacs-slack"
                   :rev "8163416ce7d1074d62df764b9071d92c63fc8888")
   :command slack-start
   :needs ((program "curl" :for "talking to Slack and fetching its files" :brew "curl")))

  (telega
   :kind app
   :name "Telega"
   :subtitle "Telegram"
   :category social
   :description "Telega, a Telegram client: your chats, groups and channels, with photos, stickers and voice notes, through telega-server, which it builds once from TDLib, Telegram's library."
   :icon "telega"
   ;; Its tags stopped at 0.8.03; a commit of master that was read.
   :package (telega :url "https://github.com/zevlg/telega.el"
                    :rev "382276c2443f644a981f67f1f2340115696453e2")
   :command telega
   ;; Homebrew's release of TDLib, 1.8.0, is older than the 1.8.66 Telega needs.
   :needs ((library "TDLib" :for "talking to Telegram, through telega-server" :brew "tdlib" :head t
                    :file "include/td/telegram/td_json_client.h")
           (program "cc" :for "building telega-server, once" :xcode t)))

  ;; Games, built into Emacs.

  (tetris
   :kind app
   :name "Tetris"
   :subtitle "Falling blocks"
   :category games
   :description "Fit the falling blocks into whole rows, which clear, before the stack reaches the top."
   :icon "tetris"
   :command tetris)

  (snake
   :kind app
   :name "Snake"
   :subtitle "Eat and grow"
   :category games
   :description "Steer a snake round the field to eat the fruit; it grows with each one, and the game ends when it runs into a wall or itself."
   :icon "snake"
   :command snake)

  (pong
   :kind app
   :name "Pong"
   :subtitle "Bats and a ball"
   :category games
   :description "The table tennis of the first video games, for two players at one keyboard."
   :icon "pong"
   :command pong)

  (gomoku
   :kind app
   :name "Gomoku"
   :subtitle "Five in a row"
   :category games
   :description "Five stones in a row on an open board, against Emacs."
   :icon "gomoku"
   :command gomoku)

  (bubbles
   :kind app
   :name "Bubbles"
   :subtitle "Pop the bubbles"
   :category games
   :description "Remove groups of touching bubbles of one colour; the bigger the group, the more it scores."
   :icon "bubbles"
   :command bubbles)

  (5x5
   :kind app
   :name "5x5"
   :subtitle "Fill the grid"
   :category games
   :description "Fill every square of the grid; each move fills or empties a square and the squares beside it."
   :icon "5x5"
   :command 5x5)

  (solitaire
   :kind app
   :name "Solitaire"
   :subtitle "Peg solitaire"
   :category games
   :description "Jump pegs over one another to take them off the board, until one is left in the middle."
   :icon "solitaire"
   :command solitaire)

  (blackbox
   :kind app
   :name "Blackbox"
   :subtitle "Find the hidden balls"
   :category games
   :description "Find the balls hidden in a black box by firing rays into it and watching where they come out."
   :icon "blackbox"
   :command blackbox)

  (mpuz
   :kind app
   :name "Mpuz"
   :subtitle "A puzzle in letters"
   :category games
   :description "A multiplication written in letters: find the digit each letter stands for."
   :icon "mpuz"
   :command mpuz)

  (hanoi
   :kind app
   :name "Towers of Hanoi"
   :subtitle "The puzzle, solved"
   :category games
   :description "The Towers of Hanoi, solved before your eyes: a tower of discs moved from peg to peg, never a larger disc on a smaller one."
   :icon "hanoi"
   :command hanoi)

  (life
   :kind app
   :name "Life"
   :subtitle "Conway's game"
   :category games
   :description "Conway's Game of Life: cells living, dying and being born, one generation after another."
   :icon "life"
   :command life)

  (dunnet
   :kind app
   :name "Dunnet"
   :subtitle "A text adventure"
   :category games
   :description "A text adventure in the manner of Zork, played by typing what to do: look, take the shovel, go east."
   :icon "dunnet"
   :command dunnet)

  (doctor
   :kind app
   :name "Doctor"
   :subtitle "The psychotherapist"
   :category games
   :description "ELIZA's psychotherapist, who answers what you tell it with questions of its own."
   :icon "doctor"
   :command doctor)

  ;; Extensions.

  (hermes
   :kind extension
   :name "Hermes"
   :subtitle "Nous Research's agent"
   :description "Hermes, Nous Research's agent, in the editor beside Claude Code and Codex: started in a terminal at the project, its sessions listed and resumed, and Emacs's state shown to it."
   :icon "hermes"
   :program "hermes"
   :install "curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash"
   :package (lispm-hermes :url "https://github.com/LispMachineLab/lispm-hermes"
                          :rev "aeb7af55924f4e8bb65e8d0df00bc0fbcd38b7c5")
   :feature lispm-hermes)

  ;; Agent roles, LispM Agent's: the App Store does not list them.

  (reviewer
   :kind role
   :name "Reviewer"
   :description "Reviews changes for bugs and risks, and reports what it finds with the places; never edits."
   :file "roles/reviewer.org")

  (researcher
   :kind role
   :name "Researcher"
   :description "Answers questions from the web and the project's files, reading sources rather than snippets, and cites them."
   :file "roles/researcher.org")

  ;; Skills, LispM Agent's too.

  (feeds
   :kind skill
   :name "Read feeds"
   :description "Lets agents search and read your Elfeed entries, tag them, mark them read and fetch new ones."
   :file "skills/feeds.org"
   :requires (elfeed))

  (music
   :kind skill
   :name "Play music"
   :description "Lets agents find, play, pause and skip music with EMMS, and say what is playing."
   :file "skills/music.org"
   :requires (emms))

  (check-security
   :kind skill
   :name "Check security"
   :description "Lets agents scan what they are given to run, read Security's findings and explain them; only you trust a server or set a finding aside."
   :file "skills/check-security.org"
   :requires (security))

  (chat-irc
   :kind skill
   :name "Chat on IRC"
   :description "Lets agents list your IRC conversations in ERC with what is unread, read and search what was said, and send a message once you approve it."
   :file "skills/chat-irc.org"
   :requires (erc))))
