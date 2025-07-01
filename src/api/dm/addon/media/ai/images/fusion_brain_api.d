module api.dm.addon.media.ai.images.fusion_brain_api;

import api.core.components.units.services.application_unit : ApplicationUnit;
import api.core.contexts.context : Context;
import api.core.configs.keyvalues.config : Config;
import api.core.loggers.logging : Logging;

import api.core.utils.text : escapeunw;

import std;
import std.net.curl;
import etc.c.curl : CurlError, CurlInfo;

enum FusionStyle
{
    none = "DEFAULT",
    kandinsky = "KANDINSKY",
    detailphoto = "UHD",
    anime = "ANIME",
}

enum FusionStatus
{
    initial = "INITIAL",
    processing = "PROCESSING",
    done = "DONE",
    fail = "FAIL"
}
/**
 * Authors: initkfs
 */
class FusionBrainApi : ApplicationUnit
{
    size_t maxPromptLength = 1000;
    size_t maxClientBufferSize = size_t.max;

    size_t clientConnTimeoutMsecs = 5000;
    size_t clientDataTimeoutMsecs = 5000;
    size_t clientDnsTimeoutMsecs = 5000;

    string apiUrl = "https://api-key.fusionbrain.ai";

    static immutable
    {
        string configXKey = "fusionKeyAPI";
        string configkXSecretKey = "fusionSecretAPI";
    }

    string xKeyValue;
    string xSecretKeyValue;

    string xKeyHeader = "X-Key";
    string xSecretKeyHeader = "X-Secret";

    void delegate(ubyte[]) onImageBinaryData;

    //v % 64 == 0
    enum defaultImageSize = 256;
    enum defaultPrompt = "Cat image";
    enum defaultStyle = FusionStyle.detailphoto;

    this(Logging logging, Config config, Context context)
    {
        super(logging, config, context);

        if (config.hasKey(configXKey))
        {
            xKeyValue = config.getNotEmptyString(configXKey).get;
        }

        if (config.hasKey(configkXSecretKey))
        {
            xSecretKeyValue = config.getNotEmptyString(configkXSecretKey).get;
        }
    }

    string[string] createClientHeaders(string url = null)
    {
        typeof(return) headers;

        if (xKeyValue.length == 0)
        {
            throw new Exception("X key value is empty");
        }

        if (xSecretKeyValue.length == 0)
        {
            throw new Exception("X secret key value is empty");
        }

        headers[xKeyHeader] = "Key " ~ xKeyValue;
        headers[xSecretKeyHeader] = "Secret " ~ xSecretKeyValue;
        return headers;
    }

    HTTP createClient(string url = null)
    {
        HTTP client = url.length > 0 ? HTTP(url) : HTTP();

        if (clientConnTimeoutMsecs > 0)
        {
            import core.time : dur;

            client.connectTimeout = clientConnTimeoutMsecs.dur!"msecs";
        }

        if (clientDataTimeoutMsecs > 0)
        {
            import core.time : dur;

            client.dataTimeout = clientDataTimeoutMsecs.dur!"msecs";
        }

        if (clientDnsTimeoutMsecs > 0)
        {
            import core.time : dur;

            client.dnsTimeout = clientDnsTimeoutMsecs.dur!"msecs";
        }

        setHeaders(client, url);

        return client;
    }

    void setHeaders(HTTP client, string url = null)
    {
        foreach (header, value; createClientHeaders(url))
        {
            client.addRequestHeader(header, value);
        }
    }

    JSONValue buildGenQuery(string prompt = defaultPrompt, FusionStyle style = defaultStyle, size_t w = defaultImageSize, size_t h = defaultImageSize, string negPrompt = null)
    {
        import std.conv : text, to;
        import std.json : JSONValue, toJSON;

        if (prompt.length > maxPromptLength)
        {
            import std.format : format;

            throw new Exception(format("Prompt too long, expected size %s, but received: %s", maxPromptLength, prompt
                    .length));
        }

        if (negPrompt.length > 0 && negPrompt.length > maxPromptLength)
        {
            import std.format : format;

            throw new Exception(format("Negative prompt too long, expected size %s, but received: %s", maxPromptLength, negPrompt
                    .length));
        }

        string[string] jsonMap;
        jsonMap["type"] = "GENERATE";
        if (negPrompt.length > 0)
        {
            jsonMap["negativePromptDecoder"] = negPrompt;
        }

        JSONValue root = JSONValue(jsonMap);
        root["numImages"] = 1;
        root["style"] = cast(string) style;

        // 1:1 / 2:3 / 3:2 / 9:16 / 16:9
        root["width"] = w;
        root["height"] = h;

        root.object["generateParams"] = JSONValue(["query": prompt]);

        return root;
    }

    struct ClientContext
    {
        HTTP client;

        Appender!(char[]) buffer;
        size_t maxClientBufferSize = size_t.max;

        this(HTTP client)
        {
            this.client = client;
            client.onReceive = (ubyte[] data) { return fill(data); };
        }

        CurlCode perform(ThrowOnError throwOnError = Yes.throwOnError) => client.perform(
            throwOnError);

        size_t fill(ubyte[] data)
        {
            auto newLen = buffer.length + data.length;
            if (newLen > maxClientBufferSize)
            {
                return 0;
            }
            buffer ~= cast(string) data;
            return data.length;
        }

        void clear()
        {
            buffer.clear;
        }

        inout(char[]) data() inout => buffer.data;
    }

    ClientContext* newClientContext(string url = null) => new ClientContext(createClient(url));

    string requestPipeline(ClientContext* clientCtxPtr = null)
    {
        ClientContext* ctx = clientCtxPtr ? clientCtxPtr : newClientContext;

        assert(apiUrl[$ - 1] != '/');

        const clientUrl = apiUrl ~ "/key/api/v1/pipelines";
        ctx.client.url = clientUrl;
        ctx.client.method = HTTP.Method.get;

        logger.trace("Build client for pipeline url: ", clientUrl);

        string pipelineId;

        immutable pipelineErrMsg = "Pipeline request error.";

        try
        {
            CurlCode code = ctx.perform;

            logger.tracef("Received pipeline response, code %s, data len: %s", code, ctx
                    .buffer
                    .data.length);

            auto jsonResultArray = ctx.buffer.data.parseJSON;
            if (jsonResultArray.type != JSONType.array)
            {
                import std.format : format;

                throw new Exception(format("JSON result is not an array: %s", escapeunw(
                        jsonResultArray.toString)));
            }

            auto jsonResult = jsonResultArray[0];

            string jsonStatus;
            if (const mustBeStatus = "status" in jsonResult)
            {
                //"status":401
                if (mustBeStatus.type != JSONType.string)
                {
                    import std.format : format;

                    throw new Exception(format("JSON status is not a string: %s", escapeunw(
                            jsonResult.toString)));
                }

                jsonStatus = mustBeStatus.str;

                if (jsonStatus != "ACTIVE")
                {
                    import std.format : format;

                    throw new Exception(format("Invalid JSON status, expected ACTIVE, but received: %s", escapeunw(
                            jsonResult.toString)));
                }
            }
            else
            {
                import std.format : format;

                throw new Exception(format("Not found status in JSON response: ", escapeunw(
                        jsonResult.toString)));
            }

            string modelId;
            string modelName;
            float modelVer = 0;

            if (const mustBeModelId = "id" in jsonResult)
            {
                modelId = mustBeModelId.str;
            }

            if (const mustBeModelName = "nameEn" in jsonResult)
            {
                modelName = mustBeModelName.str;
            }

            if (const mustBeModelVer = "version" in jsonResult)
            {
                modelVer = mustBeModelVer.floating;
            }

            if (modelId.length == 0)
            {
                throw new Exception("Not found model ID in response");
            }

            logger.tracef("Found pipeline model %s:%s, id: %s", modelName, modelVer, modelId);
            pipelineId = modelId;
        }
        catch (Exception e)
        {
            logger.errorf("%s Pipeline exception, buffer: %s. %s", pipelineErrMsg, escapeunw(
                    ctx.buffer.data), e);
        }

        return pipelineId;
    }

    string requestGenerate(string pipelineId, string prompt = defaultPrompt, FusionStyle style = defaultStyle, size_t w = defaultImageSize, size_t h = defaultImageSize, string negPrompt = null, ClientContext* clientCtxPtr = null)
    {
        ClientContext* ctx = clientCtxPtr ? clientCtxPtr : newClientContext;

        assert(apiUrl[$ - 1] != '/');
        const clientUrl = apiUrl ~ "/key/api/v1/pipeline/run";
        ctx.client.url = clientUrl;
        ctx.client.method = HTTP.Method.post;

        logger.trace("Create client for pipeline run: ", clientUrl);

        immutable errMsg = "Pipeline running error.";

        auto promptJson = buildGenQuery(prompt, style, w, h, negPrompt);

        //multipart/form-data
        //"---------------------------" ~ to!string(rnd);
        string boundary = "___mfboundary___";
        ctx.client.addRequestHeader("Content-Type", "multipart/form-data; boundary=" ~ boundary);

        string formData = "--" ~ boundary ~ "\r\n" ~
            "Content-Disposition: form-data; name=\"pipeline_id\"\r\n\r\n" ~
            pipelineId ~ "\r\n" ~
            "--" ~ boundary ~ "\r\n" ~
            "Content-Disposition: form-data; name=\"params\"\r\n" ~
            "Content-Type: application/json\r\n\r\n" ~
            promptJson.toString ~ "\r\n" ~
            "--" ~ boundary ~ "--\r\n";

        ctx.client.postData = formData;

        string pipelineUUID;

        try
        {
            CurlCode code = ctx.perform;
            logger.tracef("Received running response, code %s, data len: %s", code, ctx
                    .buffer
                    .data.length);

            auto jsonResult = ctx.buffer.data.parseJSON;

            if (const mustBeUuid = "uuid" in jsonResult)
            {
                if (mustBeUuid.type != JSONType.string)
                {
                    import std.format : format;

                    throw new Exception(format("%s Invalid pipeline UUID: ", errMsg, escapeunw(
                            jsonResult.toString)));
                }

                pipelineUUID = mustBeUuid.str;
            }
        }
        catch (Exception e)
        {
            logger.errorf("Pipeline running exception %s, response buffer: %s", e, escapeunw(
                    ctx.buffer.data));
        }

        return pipelineUUID;
    }

    bool requestStatusIsContinue(string pipelineId, ClientContext* clientCtxPtr = null)
    {
        ClientContext* ctx = clientCtxPtr ? clientCtxPtr : newClientContext;

        assert(apiUrl[$ - 1] != '/');
        const clientUrl = apiUrl ~ "/key/api/v1/pipeline/status/" ~ pipelineId;
        ctx.client.url = clientUrl;
        ctx.client.method = HTTP.Method.get;

        logger.trace("Create client for pipeline check: ", clientUrl);

        immutable errMsg = "Pipeline checking error.";

        try
        {
            CurlCode code = ctx.perform;
            logger.tracef("Received pipeline status, code %s, data len: %s", code, ctx
                    .buffer
                    .data.length);

            auto jsonResult = ctx.buffer.data.parseJSON;

            if (const mustBeStatus = "status" in jsonResult)
            {
                if (mustBeStatus.type != JSONType.string)
                {
                    logger.errorf("Invalid pipeline status: ", escapeunw(
                            jsonResult.toString));
                    return false;
                }

                string jsonStatus = mustBeStatus.str;
                logger.trace("Received pipeline status: ", escapeunw(jsonStatus));

                if (jsonStatus == "DONE")
                {
                    if (const mustBeResult = "result" in jsonResult)
                    {
                        if (mustBeResult.type != JSONType.object)
                        {
                            import std.format : format;

                            throw new Exception(format("Done, but result is not a object: %s", escapeunw(
                                    mustBeResult.toString)));
                        }

                        auto resultObj = mustBeResult.object;

                        if (const mustBeFilesArr = "files" in resultObj)
                        {
                            //TODO chck array;
                            auto filesArr = mustBeFilesArr.array;
                            auto file = filesArr[0];
                            auto base64 = file.str;

                            if (base64.length % 4 != 0)
                            {
                                import std.conv : text;

                                throw new Exception(text("Invalid base64 length from response: ", base64
                                        .length));
                            }

                            import std.base64 : Base64;

                            //std.base64.Base64Exception
                            ubyte[] decoded = Base64.decode(base64);

                            if (onImageBinaryData)
                            {
                                onImageBinaryData(decoded);
                            }
                        }
                        else
                        {
                            throw new Exception("Found result, but no files");
                        }
                    }
                    else
                    {
                        throw new Exception("DONE, but result not found");
                    }

                    return false;
                }
                else if (jsonStatus == "FAIL")
                {
                    //"errorDescription": "string",
                    logger.errorf(errMsg ~ "FAIL, ", escapeunw(jsonResult.toString));
                    return false;
                }
            }
        }
        catch (Exception e)
        {
            logger.errorf(errMsg ~ "Exception %s", e);
            return false;
        }

        return true;
    }

    bool requestAvailability(string pipelineId, ClientContext* clientCtxPtr = null)
    {
        assert(apiUrl[$ - 1] != '/');

        import std.format : format;

        string pipeUrl = format("/key/api/v1/pipeline/%s/availability", pipelineId);
        const clientUrl = apiUrl ~ pipeUrl;

        ClientContext* ctx = clientCtxPtr ? clientCtxPtr : newClientContext;
        ctx.client.url = clientUrl;
        ctx.client.method = HTTP.Method.get;

        logger.trace("Create client for pipeline availability: ", clientUrl);

        immutable errMsg = "Availability checking error.";

        try
        {
            CurlCode code = ctx.perform;
            logger.tracef("Received availability status, code %s, data len: %s", code, ctx
                    .buffer
                    .data.length);

            //"pipeline_status": "DISABLED_BY_QUEUE"
            auto jsonResult = ctx.buffer.data.parseJSON;

            if (const mustBeStatus = "status" in jsonResult)
            {
                auto status = mustBeStatus.str;
                if (status == "ACTIVE")
                {
                    return true;
                }

                logger.trace("Found status in availability response, but no active: ", escapeunw(status));
            }
            else
            {
                logger.error("Not found status in availability response: ", escapeunw(
                        jsonResult.toString));
                return false;
            }
        }
        catch (Exception e)
        {
            logger.errorf(errMsg ~ "Exception %s, response buffer: %s", e, escapeunw(
                    ctx.buffer.data));
        }

        return false;
    }

    void download(string prompt = defaultPrompt, FusionStyle style = defaultStyle, size_t w = defaultImageSize, size_t h = defaultImageSize, string negPrompt = null)
    {
        ClientContext* ctx = newClientContext;

        string pipelineId = requestPipeline(ctx);
        if (pipelineId.length == 0)
        {
            logger.error("Not found FusionAPI pipeline");
            return;
        }

        ctx.clear;

        if (!requestAvailability(pipelineId, ctx))
        {
            logger.trace("Server API not available");
            return;
        }

        ctx.clear;

        string newId = requestGenerate(pipelineId, prompt, style, w, h, negPrompt, ctx);
        if (newId.length == 0)
        {
            logger.error("New pipeline UUID is empty");
            return;
        }

        ctx.clear;
        ctx.client.clearRequestHeaders;
        setHeaders(ctx.client);

        logger.trace("Receive new pipeline UUID: ", newId);

        import core.thread.osthread;
        import core.time : dur;

        size_t maxChecks = 10;
        size_t currentCheck;
        while (true)
        {
            ctx.clear;
            if (!requestStatusIsContinue(newId, ctx))
            {
                logger.trace("Break api loop");
                break;
            }
            Thread.sleep(4.dur!"seconds");

            currentCheck++;
            if (currentCheck >= maxChecks)
            {
                logger.trace("Break checking loop on timeout");
                break;
            }
        }
    }

}

unittest
{
    import api.core.loggers.null_logging : NullLogging;
    import api.core.configs.keyvalues.null_config : NullConfig;
    import api.core.contexts.null_context : NullContext;

    auto fusionApi = new FusionBrainApi(new NullLogging, new NullConfig, new NullContext);
    fusionApi.xKeyValue = "xkey";
    fusionApi.xSecretKeyValue = "xsecretkey";

    //Test headers
    auto headers = fusionApi.createClientHeaders;
    assert(headers[fusionApi.xKeyHeader] == "Key xkey");
    assert(headers[fusionApi.xSecretKeyHeader] == "Secret xsecretkey");

    //Test generative query
    auto genQueryRoot = fusionApi.buildGenQuery("test prompt", FusionStyle.anime, 400, 200, "neg prompt");
    assert(genQueryRoot["type"].str == "GENERATE");
    assert(genQueryRoot["width"].uinteger == 400);
    assert(genQueryRoot["height"].uinteger == 200);
    assert(genQueryRoot["numImages"].integer == 1);
    assert(genQueryRoot["style"].str == cast(string) FusionStyle.anime);
    assert(genQueryRoot["generateParams"]["query"].str == "test prompt");
    assert(genQueryRoot["negativePromptDecoder"].str == "neg prompt");

}
