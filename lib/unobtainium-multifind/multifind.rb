# coding: utf-8
#
# unobtainium-multifind
# https://github.com/jfinkhaeuser/unobtainium-multifind
#
# Copyright (c) 2016 Jens Finkhaeuser and other unobtainium-multifind contributors.
# All rights reserved.
#

require 'unobtainium'

module Unobtainium
  ##
  # MultiFind namespace
  module MultiFind
    ##
    # Driver module implementing multi find functionality.
    module DriverModule

      ##
      # Default options. This hash is also used to detect if any of the Hashes
      # passed to #multifind is an options Hash; it is considered one if it
      # contains any of the keys specified here.
      DEFAULT_OPTIONS = {
        # If true, raises on error instead of returning nil
        raise_on_error: false,
        # If true, returns the error object instead of nil
        return_errors: false,
        # If :all is specified, all results are returned.
        # If :first is specified, the first non-error result is
        #   returned.
        # If :last is specified, the last non-error result is
        #   returned.
        find: :all,
        # Defaults to only finding :displayed? elements. You can use any method
        # that Selenium::WebDriver::Element responds to, or :exists? if you only
        # care whether the element exists.
        check_element: :displayed?,
        # The default method to perform the actual find is :find_element, but
        # you can override this here. The most sensible case would be to use
        # :find_elements instead, of course.
        find_method: :find_element,
      }.freeze

      class << self
        ##
        # Returns true if the implementation has `#find_element`, false
        # otherwise.
        def matches?(impl)
          return impl.respond_to?(:find_element)
        end
      end # class << self

      ##
      # Current options for multifind
      attr_accessor :multifind_options
      @multifind_options = DEFAULT_OPTIONS

      ##
      # Find multiple elements. Each argument is a Hash of selector options
      # that are passed to options[:find_method]. If one argument contains keys
      # from the DEFAULT_OPTIONS Hash, it is instead treated as an options Hash
      # for the #multifind method.
      # @return Array of found elements or nil entries if no matching element
      #   was found.
      def multifind(*args)
        # Parse options
        options, selectors = multifind_parse_options(*args)

        # Now find elements
        results = []
        selectors.each do |selector|
          begin
            results << send(options[:find_method], selector)
          rescue ::Selenium::WebDriver::Error::NoSuchElementError => err
            if options[:raise_on_error]
              raise
            end
            if options[:return_errors]
              results << err
              next
            end
            results << nil
          end
        end

        # Filter results, if necessary
        return multifind_filter_results(options, results)
      end

      alias find multifind

      private

      ##
      # Distinguishes between option hashes and selectors by detecting Hash
      # arguments with keys from DEFAULT_OPTIONS. Those are considered to be
      # options, and merged with any preceding option hashes, where latter
      # occurrences overwrite earlier ones.
      def multifind_parse_options(*args)
        # Sanity
        if @multifind_options.nil?
          @multifind_options = DEFAULT_OPTIONS
        end

        # Distinguish between options and selectors
        options = {}
        selectors = []
        args.each do |arg|
          # Let the underlying API handle all non-Hashes
          if not arg.is_a?(Hash)
            selectors << arg
            next
          end

          # See if it contains any of the keys we care about
          option_keys = DEFAULT_OPTIONS.keys
          diff = option_keys - arg.keys
          if diff != option_keys
            options.merge!(arg)
            next
          end

          selectors << arg
        end
        options = @multifind_options.merge(options)
        options = DEFAULT_OPTIONS.merge(options)

        # Ensure that the 'find' option contains correct
        # values only.
        if not [:all, :first, :last].include?(options[:find])
          raise ArgumentError, ":find option must be one of :all, :first or "\
            ":last, but is: #{options[:find]}"
        end

        # Ensure that 'check_element' contains only valid options.
        elem_klass = ::Selenium::WebDriver::Element
        if options[:check_element] != :exists? and
           not elem_klass.instance_methods.include?(options[:check_element])
          raise ArgumentError, ":check_element must either be :exists? or "\
            "a boolean method that ::Selenium::WebDriver::Element responds to, "\
            "but got: #{options[:check_element]}"
        end

        return options, selectors
      end

      ##
      # Filters results from multifind; this largely means honouring the
      # :find option.
      def multifind_filter_results(options, results)
        results = multifind_collapse_results(options, results)

        # If we're only checking for existence, we're done here.
        if options[:check_element] == :exists?
          return results
        end

        # Filter all results according to the :check_element option
        filtered = results.map do |result|
          if result.is_a? Array
            next result.map do |inner|
              next apply_filter(inner, options)
            end
          end
          next apply_filter(result, options)
        end

        return filtered
      end

      ##
      # Collapses results to only return what's specified by :find.
      def multifind_collapse_results(options, results)
        # That was easy!
        if options[:find] == :all
          return results
        end

        # Filtering :first and :last is identical, except we go backwards
        # through the results array for :last.
        if options[:find] == :last
          results.reverse!
        end

        # We now return the first non-nil, non-error result
        results.each do |result|
          if result.nil?
            next
          end
          if result.is_a?(::Selenium::WebDriver::Error::NoSuchElementError)
            next
          end
          return [result]
        end

        # If we're here then we have no results, but want :first
        # or :last. An empty result is appropriate.
        return []
      end

      ##
      # Applies the :check_element filter
      def apply_filter(elem, options)
        if elem.nil?
          return elem
        end

        if elem.is_a?(::Selenium::WebDriver::Error::NoSuchElementError)
          return elem
        end

        if elem.send(options[:check_element])
          return elem
        end
        return nil
      end
    end # module DriverModule
  end # module MultiFind
end # module Unobtainium

::Unobtainium::Driver.register_module(
    ::Unobtainium::MultiFind::DriverModule,
    __FILE__
)
