# unobtainium-multifind

This gem provides a driver module for [unobtainium](https://github.com/jfinkhaeuser/unobtainium)
allowing for more easily finding (one of) multiple elements.

[![Gem Version](https://badge.fury.io/rb/unobtainium-multifind.svg)](https://badge.fury.io/rb/unobtainium-multifind)
[![Build status](https://travis-ci.org/jfinkhaeuser/unobtainium-multifind.svg?branch=master)](https://travis-ci.org/jfinkhaeuser/unobtainium-multifind)

To use it, require it after requiring unobtainium, then create the any driver
with a Selenium API:

```ruby
require 'unobtainium'
require 'unobtainium-multifind'

include Unobtainium::World

driver.navigate.to('http://finkhaeuser.de')

elems = driver.multifind({ xpath: '//some-element' },
                         { xpath: '//other-element' })

# Entries will be nil if nothing is found by this xpath
puts elems.length # => 2
```
