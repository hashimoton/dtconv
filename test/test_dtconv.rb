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
        # D MON Y
        "4-Mar-2001",
        "04-March-2001",
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
      "06:07:08.000" => [
        "06:07:08+09:00",
        "6:7:8 am +09:00",
        "6時7分8秒 +9:00",
        "06時07分08秒+900",
        "06時07分08秒JST",
        "6:7:8 JST+0900",
        "6:07:08 UTC+900"
      ],
    }
  
    test_times.each_pair do |expected, probes|
      probes.each do |probe|
        @ch.run(probe)
        assert_match /^\d{4}-\d{2}-\d{2} #{expected} [+-]\d{2}:\d{2}$/, @ch.output
      end
    end
  end
  
  
  def test_date_time
    test_date_times = {
      "2001-03-04 12:34:56.000 +09:00" => [
        "2001-03-04 12:34:56.000 +09:00",
        "Sun Mar  4 12:34:56 JST 2001",
        "2001年 3月 4日 日曜日 12:34:56 JST"
      ],
      "1970-01-01 04:30:41.123 +05:30" => [
        "1970-01-01 04:30:41.123 +05:30",
        "4:30:41.123am IST January 1, 1970"
      ],
      "1970-01-01 00:00:00.000 +00:00" => [
        "1970-01-01 00:00:00.000 +00:00",
        "1970-01-01T00:00:00.000Z",
        "Jan 1 1970 00:00:00UTC"
      ],
      "1999-05-24 23:59:59.000 -08:00" => [
        "1999-05-24 23:59:59.000 -08:00",
        "24/05/1999 23:59:59 PST",
        "24 May, 1999 11:59:59.000p.m. PST",
        "5-24-1999 23:59:59.000 -800"
      ],
    }
    
    test_date_times.each_pair do |expected, probes|
      probes.each do |probe|
        @ch.run(probe)
        assert_equal expected, @ch.output.chomp
      end
    end
  end
  
  
  def test_epoch_time
    ENV["TZ"] = "JST-9"
    
    test_digits = {
      "2001-03-04 12:34:56.000 +09:00" => [
        "983676896",
        "983676896000"
      ],
      "2021-03-04 12:34:56.000 +09:00" => [
        "1614828896",
        "1614828896000"
      ],
      "2021-03-04 12:34:56.789 +09:00" => [
        "1614828896789"
      ],
    }
    
    test_digits.each_pair do |expected, probes|
      probes.each do |probe|
        @ch.run(probe)
        assert_equal expected, @ch.output.chomp
      end
    end
  end
  
  
  def test_input_format
    @ch.run("-p %y=%m=%d 01=02=03")
    assert_match /^2001-02-03/, @ch.output.chomp
  end
  
  
  def test_output_format
    @ch.run('-f "%Y/%m/%d %X" 1985-04-01 7:06:5pm')
    assert_equal "1985/04/01 19:06:05", @ch.output.chomp
    
    @ch.run('-f "%Y/%m/%d %X [%:z]" 1985-04-01 7:06:5pm -16:00')
    assert_equal "1985/04/01 19:06:05 [-16:00]", @ch.output.chomp
    
    @ch.run('-f "%Y/%m/%d %X [%:z]" 1985-04-01 7:06:5pm -1200')
    assert_equal "1985/04/01 19:06:05 [-12:00]", @ch.output.chomp
  end
  
  
  def test_input_output_format
    @ch.run('-p %y=%m=%d -f %Y/%m/%d 01=02=03')
    assert_equal "2001/02/03", @ch.output.chomp
  end
  
  
  def test_output_time_zone
    @ch.run('-o +05:30 2021-02-28 19:30:45z')
    assert_equal "2021-03-01 01:00:45.000 +05:30", @ch.output.chomp
  end

end

# EOF

