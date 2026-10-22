EMMS, the Emacs Multimedia System, plays your music from Emacs.  It remembers the tracks you give
it, with their tags, lets you browse them by artist, album, genre or year, and plays them through
a player program.

## What it does

- Keeps a library of every track you have added, its tags read once and cached.
- Browses the library as a tree: artists, then their albums, then the tracks.
- Plays a playlist, track after track, pausing, stopping and skipping as you ask.
- On a Mac, reads the library of the Music app without changing it: every song Music keeps a file
  of, its tags, and its playlists.  macOS asks once whether LispM Music Library, the small program
  that reads it, may do so.  Songs streamed from Apple Music, and those bought protected, play in
  Music only.

## Using it

The buttons along the top of its window are **Pause** (or **Play**), **Stop**, **Previous** and
**Next**; the bottom of the window says what is playing.  The **Library** menu holds **Import Music
Library**, **Add Folder…** and **Add File…**, then the playlists read from Music, each playing
when chosen.

- `n` and `p` move up and down the tree; `SPC` or `TAB` opens or closes the line point is on.
- `RET` adds what is on the line, a track, an album or all of an artist, to the playlist; `C-j`
  adds it and plays it.
- `b 1` browses by artist, `b 2` by album, `b 3` by genre and `b 4` by year.
- `s a` searches the artists, `s t` the titles.
- `C` empties the playlist.

## What it needs

- **mpv** plays the music.  Without it, macOS's own `afplay` plays MP3, AAC, Apple Lossless, WAV,
  AIFF and FLAC, and pauses, but cannot seek nor play radio streams.
- **exiftool** reads the tags of AAC and Apple Lossless files, of which a Music library is mostly
  made.  Without it, EMMS takes the tags Spotlight has read, through `mdls`.  MP3, FLAC, Ogg and
  Opus files EMMS reads by itself.

The App Store installs both.

## Where it comes from

Jorgen Schäfer began EMMS in 2003.  It is part of the GNU Project, written by the Emms developers
and maintained by Yoni Rabkin; see [its home page](https://www.gnu.org/software/emms/).
