# coding: utf-8
#
# unobtainium-multifind
# https://github.com/jfinkhaeuser/unobtainium-multifind
#
# Copyright (c) 2016 Jens Finkhaeuser and other unobtainium-multifind contributors.
# All rights reserved.
#
require 'spec_helper'

require 'unobtainium'

DRIVER = :headless
# DRIVER = :firefox
TEST_URL = 'file://' + Dir.pwd + '/spec/data/foo.html'

class Tester
  include ::Unobtainium::World
end # class Tester

describe 'Unobtainium::MultiFind::DriverModule' do
  before :each do
    @tester = Tester.new
  end

  describe "module interface" do
    it "passes unobtainium's interface checks" do
      expect do
        require 'unobtainium-multifind'
      end.to_not raise_error(LoadError)
    end

    it "exposes find methods" do
      drv = @tester.driver(DRIVER)
      expect(drv.respond_to?(:find)).to be_truthy
      expect(drv.respond_to?(:multifind)).to be_truthy
    end
  end

  describe "find functionality" do
    it "can find a single element" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)
      elem = drv.find(xpath: '//foo/bar')
      expect(elem).not_to be_nil
      expect(elem).not_to be_empty
      expect(elem.length).to eql 1
      expect(elem[0]).not_to be_nil
    end

    it "can find multiple elements" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)
      # rubocop:disable Style/BracesAroundHashParameters
      elem = drv.find({ xpath: '//foo/bar' },
                      { xpath: '//something' })
      # rubocop:enable Style/BracesAroundHashParameters
      expect(elem).not_to be_nil
      expect(elem).not_to be_empty
      expect(elem.length).to eql 2
      expect(elem[0]).not_to be_nil
      expect(elem[1]).not_to be_nil
    end

    it "returns nil for elements not found" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)
      # rubocop:disable Style/BracesAroundHashParameters
      elem = drv.find({ xpath: '//does-not-exist' },
                      { xpath: '//foo' })
      # rubocop:enable Style/BracesAroundHashParameters
      expect(elem).not_to be_nil
      expect(elem).not_to be_empty
      expect(elem.length).to eql 2
      expect(elem[0]).to be_nil
      expect(elem[1]).not_to be_nil
    end

    it "can return only the first element" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)

      # rubocop:disable Style/BracesAroundHashParameters
      elem = drv.find({ xpath: '//foo/bar' },
                      { xpath: '//something' },
                      { find: :first })
      # rubocop:enable Style/BracesAroundHashParameters
      expect(elem).not_to be_nil
      expect(elem).not_to be_empty
      expect(elem.length).to eql 1
      expect(elem[0]).not_to be_nil
    end

    it "can return only the last element" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)

      # rubocop:disable Style/BracesAroundHashParameters
      elem = drv.find({ xpath: '//foo/bar' },
                      { xpath: '//something' },
                      { find: :last })
      # rubocop:enable Style/BracesAroundHashParameters
      expect(elem).not_to be_nil
      expect(elem).not_to be_empty
      expect(elem.length).to eql 1
      expect(elem[0]).not_to be_nil
    end

    it "can return only the last non-error element when nil is returned" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)

      # rubocop:disable Style/BracesAroundHashParameters
      elem = drv.find({ xpath: '//foo/bar' },
                      { xpath: '//does-not-exist' },
                      { find: :last })
      # rubocop:enable Style/BracesAroundHashParameters
      expect(elem).not_to be_nil
      expect(elem).not_to be_empty
      expect(elem.length).to eql 1
      expect(elem[0]).not_to be_nil
    end

    it "can return only the last non-error element when errors are returned" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)

      # rubocop:disable Style/BracesAroundHashParameters
      elem = drv.find({ xpath: '//foo/bar' },
                      { xpath: '//does-not-exist' },
                      { find: :last, return_errors: true })
      # rubocop:enable Style/BracesAroundHashParameters
      expect(elem).not_to be_nil
      expect(elem).not_to be_empty
      expect(elem.length).to eql 1
      expect(elem[0]).not_to be_nil
    end

    it "can return empty when no matches are found with :first" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)

      # rubocop:disable Style/BracesAroundHashParameters
      elem = drv.find({ xpath: '//does-not-exist' },
                      { find: :first })
      # rubocop:enable Style/BracesAroundHashParameters
      expect(elem).not_to be_nil
      expect(elem).to be_empty
    end

    it "does not find hidden elements" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)

      elem = drv.find(xpath: '//foo/hidden')
      expect(elem).not_to be_nil
      expect(elem).not_to be_empty
      expect(elem[0]).to be_nil
    end

    it "passes non-hash arguments without touching them" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)
      expect do
        drv.find(42) # not a valid selector for selenium
      end.to raise_error
    end
  end

  describe "find options" do
    it "can throw on errors" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)
      # rubocop:disable Style/BracesAroundHashParameters
      expect do
        drv.find({ xpath: '//does-not-exist' },
                 { xpath: '//foo' },
                 { raise_on_error: true })
      end.to raise_error(::Selenium::WebDriver::Error::NoSuchElementError)
      # rubocop:enable Style/BracesAroundHashParameters
    end

    it "can return errors" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)
      # rubocop:disable Style/BracesAroundHashParameters
      elems = drv.find({ xpath: '//does-not-exist' },
                       { xpath: '//foo' },
                       { return_errors: true })
      # rubocop:enable Style/BracesAroundHashParameters
      expect(elems).not_to be_nil
      expect(elems).not_to be_empty
      expect(elems.length).to eql 2
      expect(elems[0]).not_to be_nil
      expect(elems[1]).not_to be_nil
      is_error = elems[0].is_a?(::Selenium::WebDriver::Error::NoSuchElementError)
      expect(is_error).to be_truthy
    end

    it "can honour instance options" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)
      drv.multifind_options = { raise_on_error: true }
      expect do
        drv.find(xpath: '//does-not-exist')
      end.to raise_error(::Selenium::WebDriver::Error::NoSuchElementError)
    end

    it "validates :find" do
      drv = @tester.driver(DRIVER)
      drv.navigate.to(TEST_URL)

      # Good option
      drv.multifind_options = { find: :all }
      expect do
        drv.find(xpath: '//foo')
      end.not_to raise_error

      # Bad option
      drv.multifind_options = { find: :bad }
      expect do
        drv.find(xpath: '//foo')
      end.to raise_error
    end
  end
end
