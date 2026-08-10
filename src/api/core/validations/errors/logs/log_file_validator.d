module api.core.validations.errors.logs.log_file_validator;

import api.core.validations.validators.validator : Validator;

/**
 * Authors: initkfs
 */
class LogFileValidator : Validator
{
    string pattern = "[error]";
    bool isNonLoggable = true;

    protected
    {
        string logfile;
    }

    this(string logfile)
    {
        this.logfile = logfile;
    }

    override void validate()
    {
        setInvalid;

        import std.file : exists, isFile;

        try
        {
            if (!logfile.exists || !logfile.isFile)
            {
                addFail("Log file not found: " ~ logfile);
                return;
            }

            import std.mmfile;
            import std.string : indexOf;

            auto mmf = new MmFile(logfile, MmFile.Mode.read, 0, null, 0);

            auto text = cast(const(char)[]) mmf[];

            if (text.indexOf(pattern) != -1)
            {
                setInvalid("Found errors in log file: " ~ logfile);
            }
            else
            {
                setValid;
            }
        }
        catch (Exception e)
        {
            addError(e);
        }
    }

}
