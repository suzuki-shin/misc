<?php
require_once '../simpletest/unit_tester.php';
require_once '../simpletest/reporter.php';
require_once '../utils.php'; // テストしたい対象
class Test_Of_Utils extends UnitTestCase
{
    public function __construct()
    {
        parent::__construct();
    }
    public function test_psql2array()
    {
        $input = array(
            "id                 | integer                     | not null default nextval('settlement_sbps_logs_id_seq'::regclass)",
            "settlement_log_id  | integer                     | ",
            "pay_method         | text                        | ",
            "merchant_id        | text                        | ",
            "service_id         | text                        | ",
            "------",
            "id                 | integer                     | not null default nextval('settlement_sbps_logs_id_seq'::regclass)",
            "settlement_log_id  | integer                     | ",
            "pay_method         | text                        | ",
            "merchant_id        | text ",
            "service_id         | text ",
            "cust_code          | text ",
            "sps_cust_no        | text  ",
        );
        $expected = array(
            array(
                'id'                => array("integer", "not null default nextval('settlement_sbps_logs_id_seq'::regclass)"),
                'settlement_log_id' => array("integer", ""),
                'pay_method'        => array("text", ""),
                'merchant_id'       => array("text", ""),
                'service_id'        => array("text", ""),
            ),
            array(
                'id'                => array("integer", "not null default nextval('settlement_sbps_logs_id_seq'::regclass)"),
                'settlement_log_id' => array("integer", ""),
                'pay_method'        => array("text", ""),
                'merchant_id'       => array("text"),
                'service_id'        => array("text"),
                'cust_code'         => array("text"),
                'sps_cust_no'       => array("text"),
            ));
        $this->assertEqual(psql2array($input), $expected);
    }
}
$test = new Test_Of_Utils;
$test->run(new TextReporter());