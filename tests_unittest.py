import unittest
import tests_lib

class TestStringMethods(unittest.TestCase):

    def test_Ping_docker1_from_hostvm(self):
        self.assertEqual(tests_lib.ping("192.168.1.2"), True)

    def test_Ping_docker2_from_hostvm(self):
        self.assertEqual(tests_lib.ping("192.168.3.2"), True)

    def test_ping_from_docker1_to_hostvm(self):
        self.assertEqual(tests_lib.ping_from_docker("docker1","192.168.2.2", "logs/ping_dock1_to_vm.txt"), True)
    
    def test_ping_from_docker2_to_hostvm(self):
        self.assertEqual(tests_lib.ping_from_docker("docker2","192.168.2.2", "logs/ping_dock2_to_vm.txt"), True)

    def test_iperf_from_host_to_docker1(self):
        self.assertEqual(tests_lib.iperf_from_host("192.168.1.2", "logs/iperf_from_vm_to_docker1.txt"), True)
    
    def test_iperf_from_host_to_docker2(self):
        self.assertEqual(tests_lib.iperf_from_host("192.168.3.2", "logs/iperf_from_vm_to_docker2.txt"), True)

    def test_iperf_docker1_docker2(self):
        self.assertEqual(tests_lib.iperf_between_dockers("docker1", "192.168.3.2", "logs/iperf_docker1_to_docker2.txt"), True)
    
    def test_iperf_docker2_docker1(self):
        self.assertEqual(tests_lib.iperf_between_dockers("docker2", "192.168.1.2", "logs/iperf_docker2_to_docker1.txt"), True)

    def test_iperf_docker1_hostvm(self):
        self.assertEqual(tests_lib.iperf_between_dockers("docker1", "192.168.2.2", "logs/iperf_docker1_to_hostvm.txt"), True)

    def test_iperf_docker2_hostvm(self):
        self.assertEqual(tests_lib.iperf_between_dockers("docker2", "192.168.2.2", "logs/iperf_docker2_to_hostvm.txt"), True)



if __name__ == '__main__':
    unittest.main()