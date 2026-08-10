module api.core.validations.validators.validator_async;

import api.core.utils.queues.ring_buffer_spsc : RingBuffer;
import api.core.validations.validators.validator : Validator;
import core.thread.osthread : Thread;

struct ValidationMessage
{
    string message;
    bool isValid;
    bool isNonLoggable;
}

/**
 * Authors: initkfs
 */
class ValidatorAsync : Thread
{
    ValidationMessage resultMessage;
    bool isDone;

    protected
    {
        RingBuffer!(ValidationMessage, 1) result;
        //TODO array
        Validator validator;
    }

    this(Validator validator)
    {
        super(&validate);
        assert(validator);
        this.validator = validator;
        result.initialize;
    }

    void validate()
    {
        try
        {
            validator.validate;
            ValidationMessage[1] messages = [
                ValidationMessage(validator.messages, validator.isValid, validator.isNonLoggable)
            ];
            result.write(messages);
        }
        catch (Exception e)
        {
            import std.stdio : writeln, stderr;

            stderr.writeln(e);
        }
    }

    void checkResult()
    {
        ValidationMessage[1] message;
        if (result.read(message))
        {
            resultMessage = message[0];
            isDone = true;
        }
    }
}
