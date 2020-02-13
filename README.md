# MyMangaBook

A simple local website to view my manga books, base on ruby (and erb), support to mark which book I like more.

# Requirement
 * Only Ruby 2.0+ is needed.
 * HTTP server like Apache is NOT required.

# Introduction

 * run "ruby server.rb" to start the web server.
 * Manga Book should be organized in:
```
book-*/
  *.jpg
  info.yaml
```
  info.yaml contains the title and tags of the book.

 * Read the code to get more.
   * server.rb : web server, and handle request from web page.
   * web-erb/main.erb : main page to list all books.
   * web-erb/view.erb : view page to view one book.
   * web-erb/functions.rb : methods use in main/view pages.
 * Read the history to learn how it grow up.


# Reference

Sorry, all reference is in Chinese.

* AJAX tutorial: https://www.runoob.com/jquery/jquery-ajax-intro.html
* JavaScript Output: https://www.runoob.com/js/js-output.html
* HTML Tags: https://www.w3school.com.cn/tags/index.asp
