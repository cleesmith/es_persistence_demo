## Rails and Elasticsearch persistence
> This is a simple demo to assist in learning the **ActiveRecord pattern** within the **Elasticsearch::Persistence::Model** 
> as provided by the [elasticsearch-rails gem](https://github.com/elasticsearch/elasticsearch-rails "elasticsearch-rails").
>
> While coding this app, several issues were noted and solutions are provided for successfully using the **ActiveRecord pattern**. 
> After installing and logging in to the app the issues and solutions are described on the home page.

***

## Installation

### An overview YouTube video is here: https://www.youtube.com/watch?v=G1wc86moUq0

> **Some of this code is based on Railscasts episodes 250 and 270.**
>
> See: http://railscasts.com/episodes?utf8=%E2%9C%93&search=authentication
>
> I sure do miss watching Railscasts, it was something to look forward to every week.

***

### required software
* Java 1.7.0_65+
* Elasticsearch 1.2.2+
* RVM 1.25.28+  (optional but helpful)
* Ruby 2.1.1+
* Bundler 1.6.1+
* Rails 4+
* this rails app

***

### install java
on ubuntu:
```
sudo apt-get install -y python-software-properties
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install -y oracle-java7-installer
sudo update-alternatives --config java
sudo update-alternatives --config javac
sudo update-alternatives --config javaws
java -version
```
probably already installed on Windows or Mac OS X

***

### install elasticsearch
on ubuntu install 1.2.2 or the latest version of elasticsearch:
```
wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.2.2.deb
sudo dpkg -i elasticsearch-1.2.2.deb
sudo dpkg -l elasticsearch
```
on Windows or Mac OS X you can just [download from here](http://www.elasticsearch.org/overview/elkdownloads/ "download") the zip file then unzip it

either way, you can start elasticsearch using **bin/elasticsearch** or with the config file option:
> $ bin/elasticsearch --config=/__where__/__ever__/elasticsearch.yml
>
> ... to find your config file use:
>
> $ sudo find / -name "elasticsearch.yml"  ... (or somehow on Windows?)

***

### set up the run-time environment with rvm, ruby, bundler

```
cd ~
install RVM (see http://rvm.io/rvm/install for details):
... update rvm so it can find the latest ruby:
rvm get stable
rvm --version
rvm list known ... show list of available rubies
rvm install ruby-2.1.1
rvm list
rvm --default use 2.1.1
ruby -v ... should be 2.1.1
gem install bundler --no-ri --no-rdoc
```
**note:** using rvm is optional but helps with gem management

***

### install __this__ rails app

```
git clone https://github.com/cleesmith/es_persistence_demo.git
```

### bundle install and create "users" index with an admin user
```
cd es_persistence_demo
bundle install
bundle exec rails runner lib/create_admin.rb
```

### start the app
```
bundle exec thin start
```

### try the app in a web browser at x.x.x.x:3000
> if you didn't edit/change lib/create_admin.rb, you can login in using **admin**+**changeme**, otherwise use any changes you made

***

### important files to be aware of
* config/initializers/**elasticsearch.rb** ... sets elasticsearch connection
* lib/**create_admin.rb** ... creates "users" index and the admin user, note that each run will delete any existing "users" index
* **elasticsearch.yml**

***

### exercises for the learner
1. add the "Forgot your password?" feature, i.e. allow a user to reset their password
2. incorporate the existing [Music](https://github.com/elasticsearch/elasticsearch-rails/tree/master/elasticsearch-persistence/examples/music "Music") example app into this app, while fixing the issues/bugs

> If you perform either exercise successfully, please consider __giving back__ by creating a public github repo with your solution.

enjoy!
***
