# coding: utf-8

require 'minitest'
require 'minitest/autorun'
require './command_helper.rb'


class TestDtconv < MiniTest::Test

  def setup
    @ch = CommandHelper.new('../bin/dtconv')
  end
  
  def teardown
    @ch = nil
  end

  def test_empty
    @ch.run('')
    assert_match /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3} [+-]\d{2}:\d{2}$/, @ch.output
  end
 
  def test_date_only
    test_dates = {
      "2001-03-04" => [
        # YMD
        "2001/03/04",
        "2001/3/4",
        "2001.3.4",
        "2001-3-4",
        "2001,3,4",
        "2001 3 4",
        "2001  3  4",
        "2001年3月4日",
        "2001年03月04日",
        # MDY supercedes DMY
        "03/04/2001",
        "3.4.2001",
        "3  4  2001",
        # Y MON D
        "2001 Mar 4",
        "2001, March 04",
        "2001 MAR 04",
        "4.Mar.2001",
        "04, mar. 2001",
        # MON D Y
        "Mar. 4 2001",
        # MON Y D
        "March, 2001 04",
        # YYYYMMDD
        "20010304"
      ],

      "2021-12-13" => [ 
        "2021-12-13",
        "2021 13 12",
        "12/13/2021",
        "13.12.2021"
      ]
    }
    
    test_dates.each_pair do |expected, probes|
      probes.each do |probe|
        @ch.run(probe)
        assert_match /^#{expected} 00:00:00.000 [+-]\d{2}:\d{2}$/, @ch.output
      end
    end
  end
  
  
  def test_time_only
    test_times = {
      "01:02:00.000" => [
        "01:02:00",
        "1:2 am",
        "1時2分",
        "01:2"
      ],
      "01:02:03.000" => [
        "01:02:03",
        "1:2:3 am",
        "1時2分3秒",
        "01時02分03秒"
      ],
      "13:24:36.000" => [
        "13:24:36",
        "1:24:36 pm",
        "1:24:36 p.m."
      ],
      "12:34:56.789" => [
        "12:34:56.789",
        "12:34:56.789am"
      ],
    }
  
    test_times.each_pair do |expected, probes|
      probes.each do |probe|
        @ch.run(probe)
        assert_match /^\d{4}-\d{2}-\d{2} #{expected} [+-]\d{2}:\d{2}$/, @ch.output
      end
    end
  end

end

# EOF

