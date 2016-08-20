import "ECVerify.sol"

contract PaymentChannelManager is ECVerify {

    // ECVerify is a contract which exposes a "ecverify" function, used to verify that
    // the signatures match the participant addresses and the stateHash

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

    function close(
        bytes32 channelId,
        uint sequenceNumber,
        uint balance0;
        uint balance1;
        bytes signature0,
        bytes signature1
    ) {

        if (channels[channelId] == 0) {
            Error("no channel with that channelId exists");
            throw;
        }

        // copies the channel from storage into memory
        Channel memory channel = channels[channelId]

        if (!(channel.address0 == msg.sender || channel.address1 == msg.sender)) {
            Error("you are not a participant in this channel");
            throw;
        }

        bytes32 stateHash = sha3(
            channelId,
            balance0,
            balance1,
            sequenceNumber
        );

        if (!ecverify(stateHash, signature0, channel.address0)) {
            Error("signature0 invalid");
            return;
        }

        if (!ecverify(stateHash, signature1, channel.address1)) {
            Error("signature1 invalid");
            return;
        }

        if (sequenceNumber <= channel.sequenceNumber) {
            Error("sequence number too low");
            return;
        }

        if ((balance0 + balance1) != (channel.balance0 + channel.balance1)) {
            Error("the law of conservation of total balances was not respected");
            return;
        }

        // delete channel storage first to prevent re-entry
        delete channels[channelId];

        if (!(channel.address0.send(balance0)) { throw; }

        if (!(channel.address1.send(balance1)) { throw; }
    }
}
