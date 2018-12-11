# Tonnerre

Tonnerre is a pure swift built, extensible, and productive Spotlight alternative. You can consider it as a global search bar with everything you are interested, or it is a text-based Siri who responds to all your requests.

## Getting Started

These instruction will get you a copy of the project up and running on your local machine for development and testing purpose. 

### Prerequisites

- Git
- Xcode with the latest Swift version (4.2)
- Carthage

### Installing

```bash
cd somewhere
git clone https://github.com/YaxinCheng/Tonnerre.git
cd Tonnerre
carthage update
open Tonnerre.xcodeproj
```

After open in Xcode, you can add a new scheme `Tonnerre` and it will build the `Tonnerre.app`

Or you can download a built version here: [Tonnerre.app](https://github.com/YaxinCheng/Tonnerre/releases/download/1.0.0/Tonnerre.app.zip)

### Built With

- [HotKey](https://github.com/soffes/HotKey) - Simple global shortcuts in macOS
- [TonnerreSearch](https://github.com/YaxinCheng/TonnerreSearch) - A necessary component for building your own Spotlight on macOS with Swift
- [LiteTableView](https://github.com/YaxinCheng/LiteTableView) - A faster and simpler table view for macOS

## Functionality

Here is what Tonnerre can offer

### Quick search for your apps and your files

When you type in a request, Tonnerre acts quickly and provides you a list of options. Besides navigating using **arrow keys**, and **Enter** to select, Tonnerre also provides quick-selection with **⌘+number**. 

![quickLaunch](https://user-images.githubusercontent.com/13768613/49770842-5da1d580-fcb4-11e8-8645-1671f2df4bee.png)

### File Search based on file names or file content

Besides simply app search and launch, Tonnerre supports file search function with keyword `file` for *search by name*, and `content`for *search by content*

![filesearch](https://user-images.githubusercontent.com/13768613/49771064-60e99100-fcb5-11e8-8a58-f0777fc1032e.png)

### Search is never enough only on local

When you can search through the local files and apps, you know this is never enough. The broader internet is our destination. So, when you need to search things online. 

Tonnerre provides you numerous options to satisfy different types of search: **Google**, **Bing**, **DuckDuckGo**, **Wikipedia**, **Google Image**, **Google Map**, and etc.. You just need to type in the keyword, and followed by the content you want to search, then it lead you to where you want to be.

#### Google

![google](https://user-images.githubusercontent.com/13768613/49771277-6398b600-fcb6-11e8-9b0b-6b7120c0a906.png)

#### Google Map

![map](https://user-images.githubusercontent.com/13768613/49768484-8624d200-fcaa-11e8-8716-58c23f134023.png)

#### Wikipedia

![wiki](https://user-images.githubusercontent.com/13768613/49768482-8624d200-fcaa-11e8-8820-0654722aed79.png)

### Only search is not productive enough, even with internet

When we search, we care more about its content. Why do we have to jump to browser or file editor to know the content? Can't we do it here?

Yes, of course! With Tonnerre, you can **preview** the option by clicking **Space** bar. It doesn't matter if it's a image, a file, or an URL, you can view it before open it.

#### Preview a file

![filePreview](https://user-images.githubusercontent.com/13768613/49768479-858c3b80-fcaa-11e8-9c26-590667e9d240.png)

#### Preview an URL

![translate](https://user-images.githubusercontent.com/13768613/49768483-8624d200-fcaa-11e8-8028-be95968dda3d.png)

### Besides search, Tonnerre has something more

Search is just one side of this app. It actually has something more, that help you do things with the least key strokes and no mouse move

#### Record your copy history

Preview is supported of course

![clipboard](https://user-images.githubusercontent.com/13768613/49768481-858c3b80-fcaa-11e8-9a1c-5132e47fd454.png)

#### Quit your program

![quit](https://user-images.githubusercontent.com/13768613/49771601-e110f600-fcb7-11e8-9bc0-b573c1f1d9fd.png)

#### Eject your external harddrives (dmg included)

![eject](https://user-images.githubusercontent.com/13768613/49771646-10bffe00-fcb8-11e8-87ea-a88af5d2258c.png)

#### Calculate the currency changes

![currency](https://user-images.githubusercontent.com/13768613/49771817-df93fd80-fcb8-11e8-995b-c4041a774c1b.png)

#### Some other functions...

Besides all these, Tonnerre also support *quick launch Browser bookmarks (Safari and Chrome supported)*, *quick launch URLs*, *calculator*, *look up dictionary*, and etc.. There are more functionalities waiting for you to explore

### Dark Mode

As Apple introduced Dark mode in macOS Mojave, Tonnerre also supports two different coloured interfaces. And it is totally based on your system settings

![darkmode](https://user-images.githubusercontent.com/13768613/49771935-65b04400-fcb9-11e8-8ee7-c71d70dad369.png)

### Extensions

At the very beginning, the word `extensible` was mentioned. According to my builtin English Dictionary:

> extensible | ikˈstensəb(ə)l | 
>
> adjective 
>
> able to be extended; extendable: an extensible architecture designed to accommodate changes.

So, Tonnerre supports extensions too. The extensions are called **TNE Script**. They are simply packed scripts with extra resource files. For more detailed info about **TNE Script**, go to: [TNEExamples](https://github.com/YaxinCheng/TNEExamples).

## License

This project is licensed under the GPLv3 Licence - see the [LICENSE.md](https://github.com/YaxinCheng/Tonnerre/blob/master/LICENSE)

