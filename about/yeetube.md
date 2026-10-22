Yeetube searches YouTube from Emacs and lists what it finds, each video with its channel, length,
views and age.  In LispM its window lays the results out as a video site does, thumbnails and all,
and plays a video in the window itself.

## What it does

- Searches YouTube without an account: Yeetube reads the site's own pages of results.
- Sorts the results by relevance, upload date, view count or rating, and fetches more of them on
  request.
- Plays a video on a page of its own in the window: YouTube's player, then the video's title and
  channel, buttons to download, save and share it, and the other results to play next.  The
  **Video** menu's **Play in mpv** plays it in a window of mpv's instead, as Yeetube does outside
  LispM.
- Downloads a video, or its sound alone, with yt-dlp.
- Keeps a list of videos saved to watch later, each under a name you give it, and a history of
  those played.
- Lists a channel's videos, and copies the address of its feed, for following it in Elfeed.

## Using it

Search with the box at the top of the window.  The **Video** menu holds everything else, with its
keys; **Settings…** sets how many results to list, the height of the videos played, where
downloads go, and a format for downloading the sound alone.

- `s` or `/` searches; `RET`, or a click, plays the video point is on.
- `C-n` and `C-p` move from video to video; `M-n` lists more results.
- `q` or `DEL` stops the video and goes back to the results.
- `d` downloads the video; `S` saves it to watch later, and `P` plays a saved one.
- `r` plays one played before; `c` lists the channel's videos.
- `C` copies the video's address, to share it; `R` copies the channel's feed.

## What it needs

- **mpv** plays videos outside the window.
- **yt-dlp** downloads them, and gives mpv what to play.

The App Store installs both.

## Where it comes from

Thanos Apollo wrote Yeetube in 2023 and publishes it under the GNU General Public License; its
home is [thanosapollo.org](https://thanosapollo.org/projects/yeetube/).  LispM installs its
release 2.3.1.
