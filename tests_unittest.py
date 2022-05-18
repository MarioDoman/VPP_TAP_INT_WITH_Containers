import unittest
import tests_lib

class TestStringMethods(unittest.TestCase):

    def test_Ping_docker1_from_hostvm(self):
        self.assertEqual(tests_lib.ping("192.168.1.2"), True)

    def test_Ping_docker2_from_hostvm(self):
        self.assertEqual(tests_lib.ping("192.168.3.2"), True)

    def test_ping_from_docker2_to_hostvm(self):
        self.assertEqual(tests_lib.ping_from_docker("docker2","192.168.3.2"), True)


if __name__ == '__main__':
    unittest.main()