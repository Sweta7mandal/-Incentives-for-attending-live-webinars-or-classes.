// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WebinarIncentives {
    struct Webinar {
        uint id;
        string title;
        uint date;
        uint reward;
        address organizer;
    }

    struct Attendance {
        bool attended;
        bool rewardClaimed;
    }

    uint public webinarCount;
    mapping(uint => Webinar) public webinars;
    mapping(uint => mapping(address => Attendance)) public attendanceRecords;

    event WebinarCreated(uint indexed webinarId, string title, uint date, uint reward, address indexed organizer);
    event AttendeeMarked(uint indexed webinarId, address indexed attendee);
    event RewardClaimed(uint indexed webinarId, address indexed attendee, uint amount);

    function createWebinar(string memory _title, uint _date, uint _reward) public payable {
        require(msg.value == _reward, "Insufficient funds for rewards");
        require(_date > block.timestamp, "Date must be in the future");

        webinarCount++;
        webinars[webinarCount] = Webinar(webinarCount, _title, _date, _reward, msg.sender);

        emit WebinarCreated(webinarCount, _title, _date, _reward, msg.sender);
    }

    function markAttendance(uint _webinarId, address _attendee) public {
        Webinar storage webinar = webinars[_webinarId];
        require(webinar.organizer == msg.sender, "Only the organizer can mark attendance");
        require(block.timestamp >= webinar.date, "Webinar has not occurred yet");

        Attendance storage attendance = attendanceRecords[_webinarId][_attendee];
        require(!attendance.attended, "Attendance already marked");

        attendance.attended = true;

        emit AttendeeMarked(_webinarId, _attendee);
    }

    function claimReward(uint _webinarId) public {
        Webinar storage webinar = webinars[_webinarId];
        Attendance storage attendance = attendanceRecords[_webinarId][msg.sender];

        require(attendance.attended, "Attendance not marked");
        require(!attendance.rewardClaimed, "Reward already claimed");

        attendance.rewardClaimed = true;

        payable(msg.sender).transfer(webinar.reward);

        emit RewardClaimed(_webinarId, msg.sender, webinar.reward);
    }

    function getWebinarDetails(uint _webinarId) public view returns (string memory, uint, uint, address) {
        Webinar storage webinar = webinars[_webinarId];
        return (webinar.title, webinar.date, webinar.reward, webinar.organizer);
    }

    receive() external payable {}
}
