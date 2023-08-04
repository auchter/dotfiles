Where possible, I have been trying to move away from reliance on third-party "cloud" services, especially those that are "free" and supported by mining data for advertising purposes. This page serves as a summary of the services I host / use, as well as the programs I use to interact with them.

# Calendar and Contacts

I run a [radicale](https://radicale.org) server to store my calendar and contacts. On my laptop, I use [vdirsyncer](https://github.com/pimutils/vdirsyncer) to sync the contacts and calendar files locally, and then use [khard](https://github.com/lucc/khard) and [khal](https://github.com/pimutils/khal) to access them. On my phone, I use [DAVx5](https://www.davx5.com/) to sync contacts and calendar, and the built-in Contacts app in GrapheneOS for contacts, and [Etar](https://f-droid.org/packages/ws.xsoh.etar/) for a calendar app.

# Notes

I use [Obsidian](https://obsidian.md) to take notes on both my laptop and phone. These are synchronized with [Syncthing](https://syncthing.net/).

# Photos

I run a [Photoprism](https://photoprism.app) instance for storing, organizing, and viewing photos. I use [Syncthing](https://syncthing.net) to automatically synchronize photos from my phone to my laptop. Currently I manually import photos from my phone and digital camera into Photoprism on occasion, but may automate this in the future.

# Location History / Timeline

I run an [OwnTracks Recorder](https://github.com/owntracks/recorder/) server and have the OwnTracks app running on my phone. In the past, I used Google's built-in location history: I downloaded this via Google Takeout and imported it into my OwnTracks Recorder instance.

# Password Manager

Currently using [Bitwarden](https://bitwarden.com), though planning to move to [Pass](https://passwordstore.org).

# Music Streaming

I run an [Airsonic](https://airsonic.github.io/) server which serves all of my music collection. On my phone, I use [DSub](https://f-droid.org/packages/github.daneren2005.dsub/) to access that server, and on my stereo I use [Mopidy](https://mopidy.com).

[beets](https://github.com/beetbox/beets) is used to manage the music collection on the server.

# RSS Feeds

I run [Miniflux](https://miniflux.app/) for tracking RSS feeds.

# Backups

I use [restic](https://restic.net) for backups. I backup nightly to [Backblaze](https://backblaze.com) and perform local backups to external hard drives on occasion.

# Email

I don't bother self-hosting email, instead I use [Migadu](https://www.migadu.com). On my laptop, I sync mail using offlineimap and read it using neomutt. On my phone, I use [K-9 Mail](https://k9mail.app/).
