#!/usr/bin/env python3
"""Minimal test — subscribe to one topic at a time to find the crash."""
import sys
import rclpy
from rclpy.node import Node
from rclpy.qos import qos_profile_sensor_data, QoSProfile, ReliabilityPolicy, HistoryPolicy

from sensor_msgs.msg import LaserScan, Range, NavSatFix
from geometry_msgs.msg import Pose

TOPICS = {
    'lidar':  ('/drone/lidar/scan',       LaserScan),
    'tof_l':  ('/drone/tof/left',         Range),
    'tof_r':  ('/drone/tof/right',        Range),
    'gps':    ('/drone/gps/fix',          NavSatFix),
    'sonar':  ('/simple_drone/sonar/out', Range),
    'pose':   ('/simple_drone/gt_pose',   Pose),
}

class TestSub(Node):
    def __init__(self, key):
        super().__init__('test_sub')
        topic, msg_type = TOPICS[key]
        # Try sensor_data QoS (best_effort, volatile)
        self.sub = self.create_subscription(
            msg_type, topic, self.cb, qos_profile_sensor_data)
        self.get_logger().info(f'Subscribed to {topic} ({msg_type.__name__}) with sensor_data QoS')
        self.count = 0

    def cb(self, msg):
        self.count += 1
        self.get_logger().info(f'Got msg #{self.count}')
        if self.count >= 3:
            self.get_logger().info('SUCCESS — 3 msgs received')
            raise SystemExit(0)

def main():
    key = sys.argv[1] if len(sys.argv) > 1 else 'lidar'
    print(f'Testing topic: {key}')
    rclpy.init()
    node = TestSub(key)
    try:
        rclpy.spin(node)
    except SystemExit:
        pass
    node.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    main()
