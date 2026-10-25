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
   :banner "elfeed"
   :about "elfeed"
   :author "Christopher Wellons"
   :license "Unlicense"
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
   :banner "emms"
   :about "emms"
   :author "Jorgen Schäfer and the Emms developers"
   :license "GPL-3.0-or-later"
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
   :banner "yeetube"
   :about "yeetube"
   :author "Thanos Apollo"
   :license "GPL-3.0-or-later"
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
   :banner "calculator"
   :about "calculator"
   :author "David Gillespie"
   :license "GPL-3.0-or-later"
   :command calc)

  (calendar
   :kind app
   :name "Calendar"
   :subtitle "Months and the diary"
   :category productivity
   :description "Emacs's calendar: months at a glance, holidays, sunrise and sunset, phases of the moon, and the diary."
   :icon "calendar"
   :banner "calendar"
   :about "calendar"
   :author "Edward M. Reingold"
   :license "GPL-3.0-or-later"
   :command calendar)

  (stickies
   :kind app
   :name "Stickies"
   :subtitle "Notes on the desktop"
   :category productivity
   :description "Mac OS 9's Stickies: notes in seven colours over the desktop, rolled up into their title bars, kept as headings of one org file that agents read too."
   :icon "stickies"
   :banner "stickies"
   :about "stickies"
   :author "LispMachineLab"
   :license "AGPL-3.0-or-later"
   :package (lispm-stickies :url "https://github.com/LispMachineLab/lispm-stickies"
                            :rev "01d6cbd324194bf7dd4b54e7b423f595ae47e9e3")
   :feature lispm-stickies)

  (security
   :kind app
   :name "Security"
   :subtitle "What agents run, checked"
   :category utilities
   :description "Checks what agents are given to run, the MCP servers and skills of LispM, Claude Code and Codex: their settings and text against rules, skills' code read as Lisp, servers' tools pinned, packages looked up in OSV."
   :icon "security"
   :banner "security"
   :about "security"
   :author "LispMachineLab"
   :license "AGPL-3.0-or-later"
   :package (lispm-security :url "https://github.com/LispMachineLab/lispm-security"
                            :rev "8739611d3b35a7cd0a6e34a6c2ce57c7cf0aaf77")
   :command lispm-security
   :requires (lispm-kit))

  (remote
   :kind app
   :name "LispM Remote"
   :subtitle "LispM from your phone"
   :category utilities
   :description "LispM from a phone or another computer, anywhere, over Rings Network: pair once with a QR code, then talk to its agents, answer what they wait on and work in its windows from lispm.ai/remote, sealed end to end, with no server of ours in between."
   :icon "remote"
   :banner "remote"
   :about "remote"
   :author "LispMachineLab"
   :license "AGPL-3.0-or-later"
   :package (lispm-remote :url "https://github.com/LispMachineLab/lispm-remote"
                          :rev "11cccae01936980e6a9fc4ca600a97e42ef5bddd"
                          :lisp-dir "lisp")
   :command lispm-remote)

  (1password
   :kind app
   :name "1Password"
   :subtitle "Passwords and codes"
   :category utilities
   :description "The vaults of 1Password through op, its command-line tool: items searched as you type, usernames, passwords and one-time codes copied and cleared from the clipboard after 90 seconds, new logins with generated passwords. Secrets are read only when used, never kept nor written to disk."
   :icon "1password"
   :banner "1password"
   :about "1password"
   :author "LispMachineLab"
   :license "AGPL-3.0-or-later"
   :package (lispm-1password :url "https://github.com/LispMachineLab/lispm-1password"
                             :rev "1bd2d027a95479aa87ca15de6663a073ec3ac6b2")
   :command lispm-1password
   :requires (lispm-kit)
   :needs ((program "op" :for "reading your vaults" :cask "1password-cli")))

  (rotom
   :kind app
   :name "Rotom"
   :subtitle "Your models, one address"
   :category utilities
   :description "Rotom, a gateway on this machine to the models of the accounts you have, a ChatGPT plan through OpenAI's Codex, xAI's Grok, Kiro, Vercel's AI Gateway, for any program speaking OpenAI's API or Anthropic's, LispM's agents among them, with no API key of its own: its daemon started and stopped, accounts signed in to in the browser, the models listed, and one chosen for LispM's agents."
   :icon "rotom"
   :banner "rotom"
   :about "rotom"
   :author "LispMachineLab"
   :license "AGPL-3.0-or-later"
   :package (lispm-rotom :url "https://github.com/LispMachineLab/lispm-rotom"
                         :rev "4ff572f7900af3fb4db4f0d0dffdae218eedd3e5")
   :command lispm-rotom
   :requires (lispm-kit)
   :needs ((program "rotom" :for "reaching the models of your accounts" :cargo "rotom")))

  ;; To chat with.

  (erc
   :kind app
   :name "ERC"
   :subtitle "IRC chat"
   :category social
   :description "ERC, Emacs's own IRC client: the networks you are on, Libera.Chat or another, each over its channels and the people talking with you, connected to again as it opens."
   :icon "erc"
   :banner "erc"
   :about "erc"
   :author "Alexander L. Belikoff"
   :license "GPL-3.0-or-later"
   :command erc-tls)

  (slack
   :kind app
   :name "Slack"
   :subtitle "Workspaces and channels"
   :category social
   :description "emacs-slack: your Slack workspaces' channels and direct messages, signed in to with the token and cookie Slack's web app signs in with, which auth-source keeps."
   :icon "slack"
   :banner "slack"
   :about "slack"
   :author "Yuya Minami"
   :license "GPL-3.0-or-later"
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
   :banner "telega"
   :about "telega"
   :author "Zajcev Evgeny"
   :license "GPL-3.0-or-later"
   ;; Its tags stopped at 0.8.03; a commit of master that was read.
   :package (telega :url "https://github.com/zevlg/telega.el"
                    :rev "382276c2443f644a981f67f1f2340115696453e2")
   :command telega
   ;; Homebrew's release of TDLib, 1.8.0, is older than the 1.8.66 Telega needs.
   :needs ((library "TDLib" :for "talking to Telegram, through telega-server" :brew "tdlib" :head t
                    :file "include/td/telegram/td_json_client.h")
           (program "cc" :for "building telega-server, once" :xcode t)))

  ;; Games, installed.

  (doom
   :kind app
   :name "LispM Doom"
   :subtitle "Freedoom, with OpenGL"
   :category games
   :description "Doom in a buffer, its levels drawn with OpenGL by dsda-doom's engine, playing Freedoom, with sound and music."
   :icon "doom"
   :banner "doom"
   :about "doom"
   :author "LispMachineLab, dsda-doom and Freedoom"
   :license "AGPL-3.0-or-later AND GPL-2.0-or-later AND BSD-3-Clause"
   ;; Release 0.1.0.
   :package (lispm-doom :url "https://github.com/LispMachineLab/lispm-doom"
                        :rev "e64443c3878b7f59edae466346db983942cb0626"
                        :lisp-dir "lisp")
   :command lispm-doom
   ;; It runs in Emacs 32, LispM's experimental install.
   :emacs 32
   :needs ((library "SDL2_mixer" :for "the game's sound and music" :brew "sdl2_mixer"
                    :file "lib/libSDL2_mixer-2.0.0.dylib")
           (library "libsndfile" :for "the game's sounds" :brew "libsndfile"
                    :file "lib/libsndfile.1.dylib")
           (library "libzip" :for "reading zipped game files" :brew "libzip"
                    :file "lib/libzip.5.dylib")))

  ;; Games, built into Emacs.

  (tetris
   :kind app
   :name "Tetris"
   :subtitle "Falling blocks"
   :category games
   :description "Fit the falling blocks into whole rows, which clear, before the stack reaches the top."
   :icon "tetris"
   :banner "tetris"
   :about "tetris"
   :author "Glynn Clements"
   :license "GPL-3.0-or-later"
   :command tetris)

  (snake
   :kind app
   :name "Snake"
   :subtitle "Eat and grow"
   :category games
   :description "Steer a snake round the field to eat the fruit; it grows with each one, and the game ends when it runs into a wall or itself."
   :icon "snake"
   :banner "snake"
   :about "snake"
   :author "Glynn Clements"
   :license "GPL-3.0-or-later"
   :command snake)

  (pong
   :kind app
   :name "Pong"
   :subtitle "Bats and a ball"
   :category games
   :description "The table tennis of the first video games, for two players at one keyboard."
   :icon "pong"
   :banner "pong"
   :about "pong"
   :author "Benjamin Drieu"
   :license "GPL-3.0-or-later"
   :command pong)

  (gomoku
   :kind app
   :name "Gomoku"
   :subtitle "Five in a row"
   :category games
   :description "Five stones in a row on an open board, against Emacs."
   :icon "gomoku"
   :banner "gomoku"
   :about "gomoku"
   :author "Philippe Schnoebelen"
   :license "GPL-3.0-or-later"
   :command gomoku)

  (bubbles
   :kind app
   :name "Bubbles"
   :subtitle "Pop the bubbles"
   :category games
   :description "Remove groups of touching bubbles of one colour; the bigger the group, the more it scores."
   :icon "bubbles"
   :banner "bubbles"
   :about "bubbles"
   :author "Ulf Jasper"
   :license "GPL-3.0-or-later"
   :command bubbles)

  (5x5
   :kind app
   :name "5x5"
   :subtitle "Fill the grid"
   :category games
   :description "Fill every square of the grid; each move fills or empties a square and the squares beside it."
   :icon "5x5"
   :banner "5x5"
   :about "5x5"
   :author "Dave Pearson"
   :license "GPL-3.0-or-later"
   :command 5x5)

  (solitaire
   :kind app
   :name "Solitaire"
   :subtitle "Peg solitaire"
   :category games
   :description "Jump pegs over one another to take them off the board, until one is left in the middle."
   :icon "solitaire"
   :banner "solitaire"
   :about "solitaire"
   :author "Jan Schormann"
   :license "GPL-3.0-or-later"
   :command solitaire)

  (blackbox
   :kind app
   :name "Blackbox"
   :subtitle "Find the hidden balls"
   :category games
   :description "Find the balls hidden in a black box by firing rays into it and watching where they come out."
   :icon "blackbox"
   :banner "blackbox"
   :about "blackbox"
   :author "F. Thomas May"
   :license "GPL-3.0-or-later"
   :command blackbox)

  (mpuz
   :kind app
   :name "Mpuz"
   :subtitle "A puzzle in letters"
   :category games
   :description "A multiplication written in letters: find the digit each letter stands for."
   :icon "mpuz"
   :banner "mpuz"
   :about "mpuz"
   :author "Philippe Schnoebelen"
   :license "GPL-3.0-or-later"
   :command mpuz)

  (hanoi
   :kind app
   :name "Towers of Hanoi"
   :subtitle "The puzzle, solved"
   :category games
   :description "The Towers of Hanoi, solved before your eyes: a tower of discs moved from peg to peg, never a larger disc on a smaller one."
   :icon "hanoi"
   :banner "hanoi"
   :about "hanoi"
   :author "Damon Anton Permezel"
   :license "LicenseRef-Public-Domain"
   :command hanoi)

  (life
   :kind app
   :name "Life"
   :subtitle "Conway's game"
   :category games
   :description "Conway's Game of Life: cells living, dying and being born, one generation after another."
   :icon "life"
   :banner "life"
   :about "life"
   :author "Kyle Jones"
   :license "GPL-3.0-or-later"
   :command life)

  (dunnet
   :kind app
   :name "Dunnet"
   :subtitle "A text adventure"
   :category games
   :description "A text adventure in the manner of Zork, played by typing what to do: look, take the shovel, go east."
   :icon "dunnet"
   :banner "dunnet"
   :about "dunnet"
   :author "Ron Schnell"
   :license "GPL-3.0-or-later"
   :command dunnet)

  ;; Classic AI: programs from the history of AI, ELIZA's Doctor built
  ;; into Emacs, MYCIN and SHRDLU in Common Lisp.

  (doctor
   :kind app
   :name "Doctor"
   :subtitle "The psychotherapist"
   :category classic-ai
   :description "ELIZA's psychotherapist, who answers what you tell it with questions of its own."
   :icon "doctor"
   :banner "doctor"
   :about "doctor"
   :author "The GNU Emacs developers"
   :license "GPL-3.0-or-later"
   :command doctor)

  (mycin
   :kind app
   :name "MYCIN"
   :subtitle "The 1970s expert system"
   :category classic-ai
   :description "MYCIN, Stanford's expert system of the 1970s: it asks about a patient and the cultures taken, names the organisms likely to infect the blood with how certain it is, and says why it asks. Norvig's Common Lisp from Paradigms of AI Programming, run unchanged."
   :icon "mycin"
   :banner "mycin"
   :about "mycin"
   :author "LispMachineLab, after Peter Norvig"
   :license "AGPL-3.0-or-later AND MIT"
   :package (lispm-mycin :url "https://github.com/LispMachineLab/lispm-mycin"
                         :rev "44714bba908ec41dafb9996c76fb0e5bc57badfe")
   :command lispm-mycin
   :requires (emacs-cl lispm-kit))

  (shrdlu
   :kind app
   :name "SHRDLU"
   :subtitle "Winograd's blocks world"
   :category classic-ai
   :description "Terry Winograd's SHRDLU of 1970 talks in English about a table of blocks, pyramids and a box, and moves them with a hand, drawn as it goes. The Common Lisp port of the 1990s, run unchanged but for fixes, fetched with git on its first start."
   :icon "shrdlu"
   :banner "shrdlu"
   :about "shrdlu"
   :author "LispMachineLab, after Terry Winograd"
   :license "AGPL-3.0-or-later"
   :package (lispm-shrdlu :url "https://github.com/LispMachineLab/lispm-shrdlu"
                          :rev "78f92887e4706a666896631ff6a14adc70a4cc28")
   :command lispm-shrdlu
   :requires (emacs-cl lispm-kit)
   :needs ((program "git" :for "fetching SHRDLU's Common Lisp on its first start" :xcode t)))

  ;; Extensions: agents for the editor, in AI Harness, then the others.

  (hermes
   :kind extension
   :name "Hermes"
   :subtitle "Nous Research's agent"
   :category ai-harness
   :description "Hermes, Nous Research's agent, in the editor beside Claude Code and Codex: started in a terminal at the project, its sessions listed and resumed, and Emacs's state shown to it."
   :icon "hermes"
   :banner "hermes"
   :about "hermes"
   :author "LispMachineLab"
   :license "AGPL-3.0-or-later"
   :program "hermes"
   :install "curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash"
   :package (lispm-hermes :url "https://github.com/LispMachineLab/lispm-hermes"
                          :rev "288b69eb755d7acd3d7f0b9e0b7fc9c1e903b353")
   :feature lispm-hermes)

  (holon
   :kind extension
   :name "Holon"
   :subtitle "Agents that keep working"
   :category ai-harness
   :description "Holon, open-source software that keeps AI agents at work on your own computer, in the editor beside Claude Code and Codex: an agent made for the project and opened in Holon's terminal UI, its agents listed by project and taken up again, their conversations read as transcripts."
   :icon "holon"
   :banner "holon"
   :about "holon"
   :author "LispMachineLab"
   :license "AGPL-3.0-or-later"
   :needs ((program "holon" :for "running Holon's agents" :brew "holon-run/tap/holon"
                    :commands (lispm-holon-new lispm-holon-setup)))
   :package (lispm-holon :url "https://github.com/LispMachineLab/lispm-holon"
                         :rev "db0c095922e27d21022cb8e6682df38737b28cf1")
   :feature lispm-holon)

  (openclaw
   :kind extension
   :name "OpenClaw"
   :subtitle "Answers in every chat"
   :category ai-harness
   :description "OpenClaw, the open-source personal assistant that answers wherever you chat with it, in the editor beside Claude Code and Codex: a session made in the project and opened in OpenClaw's terminal UI, your conversations with it, from the terminal, its web UI or a chat app, listed and taken up again, read as transcripts."
   :icon "openclaw"
   :banner "openclaw"
   :about "openclaw"
   :author "LispMachineLab"
   :license "AGPL-3.0-or-later"
   :program "openclaw"
   :install "curl -fsSL https://openclaw.ai/install.sh | bash"
   :package (lispm-openclaw :url "https://github.com/LispMachineLab/lispm-openclaw"
                            :rev "e3fa8600c9b87155bac885cabb2fc5e6a5c99576")
   :feature lispm-openclaw)

  (emacs-cl
   :kind extension
   :name "Common Lisp"
   :subtitle "Emacs Common Lisp"
   :description "Common Lisp written in Emacs Lisp, Lars Brinkhoff's emacs-cl made to run on Emacs 30 and 31: a listener, M-x emacs-cl-repl, and the Common Lisp that MYCIN and SHRDLU run on, in a batch Emacs beside yours."
   :icon "emacs-cl"
   :banner "emacs-cl"
   :about "emacs-cl"
   :author "Lars Brinkhoff, LispMachineLab"
   :license "GPL-2.0-or-later"
   :package (emacs-cl :url "https://github.com/LispMachineLab/emacs-cl"
                      :rev "62007715826889b7daaedfd27cbaa9aa864842f1")
   :feature emacs-cl)

  (lispm-kit
   :kind extension
   :name "LispM Kit"
   :subtitle "What apps are made with"
   :description "What the App Store's applications are made with, in any Emacs: each of an application's commands declared once, its key, its menu item and its button, so that Emacs's menus and the desktop's buttons and keys windows say the same."
   :icon "lispm-kit"
   :banner "lispm-kit"
   :about "lispm-kit"
   :author "LispMachineLab"
   :license "AGPL-3.0-or-later"
   :package (lispm-kit :url "https://github.com/LispMachineLab/lispm-kit"
                       :rev "5bf1944bc28e23d5d142d0e70846d5ebe3deed30")
   :feature lispm-kit)

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
   :description "Lets agents search and read your Elfeed entries, tag them, mark them read, fetch new ones and show them in Elfeed."
   :file "skills/feeds.org"
   :requires (elfeed))

  (music
   :kind skill
   :name "Play music"
   :description "Lets agents find, play, pause and skip music with EMMS, and say what is playing."
   :file "skills/music.org"
   :requires (emms))

  (sticky-notes
   :kind skill
   :name "Stick notes"
   :description "Lets agents list and read your notes in Stickies, stick a new one on the desktop and change a note's text or colour, each once you approve it."
   :file "skills/sticky-notes.org"
   :requires (stickies))

  (blocks-world
   :kind skill
   :name "Talk with SHRDLU"
   :description "Lets agents talk with SHRDLU in English, in its window: have its hand move the blocks, and ask what is where, what it did and why."
   :file "skills/blocks-world.org"
   :requires (shrdlu))

  (use-rotom
   :kind skill
   :name "Use Rotom"
   :description "Lets agents read where Rotom stands, its daemon, accounts, models and log, renew its tokens, start or restart its daemon and choose the model LispM's agents use; signing in stays yours."
   :file "skills/use-rotom.org"
   :requires (rotom))

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
   :requires (erc))

  (chat-slack
   :kind skill
   :name "Chat on Slack"
   :description "Lets agents list your Slack conversations with what is unread, read their messages and threads, search with Slack's search, and send a message once you approve it."
   :file "skills/chat-slack.org"
   :requires (slack))

  (chat-telegram
   :kind skill
   :name "Chat on Telegram"
   :description "Lets agents list your Telegram chats in Telega with what is unread, read their messages, search with Telegram's search, and send a message once you approve it."
   :file "skills/chat-telegram.org"
   :requires (telega))))
