;; -*- lisp-data -*-

;; The catalog of the LispM Store: what LispM Desktop offers to install.
;; It is data, read and never evaluated; README.org describes its format,
;; and `make check' checks it.

(:name "LispM Store"
 :items
 (;; Applications.

  (elfeed
   :kind app
   :name "Elfeed"
   :description "A reader of web feeds, RSS and Atom: blogs, news and podcasts, searched and tagged in Emacs."
   :icon "elfeed"
   ;; Release 4.2.1.
   :package (elfeed :url "https://github.com/skeeto/elfeed"
                    :rev "acbb86e342d2b8f85dfb30dce9df01db9a829c77")
   :command elfeed)

  (emms
   :kind app
   :name "EMMS"
   :description "The Emacs Multimedia System: music and streams played through mpv, mplayer or VLC, with playlists and a browser of your library."
   :icon "emms"
   :package emms
   :command emms-browser)

  (calculator
   :kind app
   :name "Calculator"
   :description "Calc, Emacs's calculator: arbitrary precision, units, matrices, algebra and calculus, in reverse Polish or algebraic notation."
   :icon "calculator"
   :command calc)

  (calendar
   :kind app
   :name "Calendar"
   :description "Emacs's calendar: months at a glance, holidays, sunrise and sunset, phases of the moon, and the diary."
   :icon "calendar"
   :command calendar)

  ;; Agent roles.

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

  ;; Skills.

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
   :requires (emms))))
