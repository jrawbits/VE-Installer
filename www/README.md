# VisionEval Download Website management

The VisionEval download website is built with the
'[Hydeout](https://github.com/fongandrew/hydeout)' theme for GitHub
pages. It uses Jekyll, a tool built in Ruby to generate web pages from
content written in Markdown, and is integrated with GitHub.

To build the website, you'll need to install Ruby and Jekyll.  Probably you're working on Windows,
which makes sense since you can preview "live".  You can also install on other architectures (e.g.
Mac or Linux).  The same steps apply after you've got a Ruby environment up and running.  See
[Jekyll Installtion](https://jekyllrb.com/docs/installation/) and particularly the [Windows
page](https://jekyllrb.com/docs/installation/windows/)

## Windows installation

If you already have Git for Windows and Rtools installed, you can probably skip the MSys2
Installation.  You need to select an instllation path that is writable (the default,
rooted at C: won't work in most enterprise environments). If you get a prompt on Windows
10 about Ruby needing firewall permissions, you can just cancel the dialog and everything
will still work (even though it might not look like it is until it's done).  None of the
gems needed for Jekyll and the website seems to required C compilation.

Here are the Windows steps (run in a shell such as Git for Windows Bash):

	- Download Ruby and install it (notes above)
	- `gem install jekyll bundler`
	- `cd www` (the folder containing this ReadMe.md)
	- `bundle install`

If you need to adjust gem versions, you can maintain the Ruby Gems with `bundle update`.

After that, you should be good to edit the website locally.

## Checking your changes to the website

Use these two commands to try out your website changes:

```
bundle exec jekyll build
bundle exec jekyll serve
```

The build instruction can be performed by make:

```
make www
```

## Deploying the website

Two `make` targets exist in the build directory.  See the ReadMe.md over there
for further instructions.  In a nutshell:

	- `make publish-www` will take your build `_site` and push it to the web server
	- `make publish-repo` will install or update the pkg-repository on the web server

You'll need to configure web server credentials, URL, and a suitable Rsync (the one
from Rtools will work) for those to work.
