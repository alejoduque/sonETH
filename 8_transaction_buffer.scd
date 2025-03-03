// Current Date and Time (UTC): 2025-03-02 05:40:49
// Current User's Login: alejoduque

(
~transactionBuffer = (
    size: 32,
    buffer: nil,
    index: 0,
    filled: false,
    
    init: {
        if(s.serverRunning) {
            ~transactionBuffer.buffer = Buffer.alloc(s, ~transactionBuffer.size);
            ~transactionBuffer.index = 0;
            ~transactionBuffer.filled = false;
            "Transaction buffer initialized with % slots.".format(
                ~transactionBuffer.size
            ).postln;
        } {
            "Server not running - buffer not created.".warn;
        };
    },
    
    add: { |value|
        if(~transactionBuffer.buffer.notNil) {
            ~transactionBuffer.buffer.set(~transactionBuffer.index, value);
            ~transactionBuffer.index = (~transactionBuffer.index + 1) % ~transactionBuffer.size;
            if(~transactionBuffer.index == 0) { ~transactionBuffer.filled = true };
            ^true;
        } {
            "Buffer not initialized".warn;
            ^false;
        };
    },
    
    clear: {
        if(~transactionBuffer.buffer.notNil) {
            ~transactionBuffer.buffer.zero;
            ~transactionBuffer.index = 0;
            ~transactionBuffer.filled = false;
            "Transaction buffer cleared.".postln;
        };
    },
    
    cleanup: {
        if(~transactionBuffer.buffer.notNil) {
            ~transactionBuffer.buffer.free;
            ~transactionBuffer.buffer = nil;
            "Transaction buffer freed.".postln;
        };
    },
    
    getStats: {
        if(~transactionBuffer.buffer.notNil) {
            (
                size: ~transactionBuffer.size,
                index: ~transactionBuffer.index,
                filled: ~transactionBuffer.filled
            )
        } {
            nil
        }
    }
);

// Initialize
~transactionBuffer.init;

// Register cleanup
ServerQuit.add({ ~transactionBuffer.cleanup });

"Transaction Buffer initialized.".postln;
)