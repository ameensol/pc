contract PaymentChannelManager {

    // the data structure for the channel
    struct Channel {
        bytes32 channelId;
        address address0;
        address address1;
        uint balance0;
        uint balance1;
        uint sequenceNumber;
    }

    // channels by Id
    mapping (bytes32 => Channel) channels;

    event Error(string message);

    function open(bytes32 channelId, address address1, uint value) {
        if (channels[channelId].channelId == channelId) {
            Error("channel with that channelId already exists");
            throw;
        }

        if (msg.sender == address1) {
            Error("you cant create a channel with yourself");
            throw;
        }

        if (value == 0) {
            Error("you can't create a payment channel with no money");
            throw;
        }

        if (msg.value != value) {
            Error("incorrect funds");
            throw;
        }

        Channel memory channel = Channel(
            channelId,
            msg.sender, // address0
            address1, // address1
            msg.value, // balance0
            0, // balance1
            0 // sequence number
        );

        channels[channelId] = channel;
    }

    function join(bytes32 channelId) {
        if (channels[channelId] == 0) {
            Error("no channel with that channelId exists");
            throw;
        }

        if (channels[channelId].address1 != msg.sender) {
            Error("the channel creator did not specify you as the second participant");
            throw;
        }

        if (msg.value != value) {
            Error("incorrect funds");
            throw;
        }

        channels[channelId].balance1 = msg.value;
    }
}
