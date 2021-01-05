#include <stdlib.h>
#include <stdint.h>

#ifndef NO_STB_VORBIS
/* #define STB_VORBIS_NO_PUSHDATA_API  */   /*  needed by miniaudio decoding logic  */
#define STB_VORBIS_HEADER_ONLY
#include "extras/stb_vorbis.c"
#endif


#define DR_FLAC_IMPLEMENTATION
#define DR_FLAC_NO_OGG
#include "extras/dr_flac.h"

#define DR_MP3_IMPLEMENTATION
#include "extras/dr_mp3.h"

#define DR_WAV_IMPLEMENTATION
#include "extras/dr_wav.h"

#define MINIAUDIO_IMPLEMENTATION
/* #define MA_NO_DECODING */
/* #define MA_NO_AAUDIO */
/* #define MA_NO_OPENSL */
/* #define MA_NO_JACK */
#define MA_NO_WEBAUDIO
#include "miniaudio.h"


#ifndef NO_STB_VORBIS
#undef STB_VORBIS_HEADER_ONLY		/* this time, do include vorbis implementation */
#include "extras/stb_vorbis.c"
#endif

#include "extra.h"


#ifdef _WIN32
int setenv(const char *name, const char *value, int overwrite)
{
    int errcode = 0;
    if(!overwrite) {
        size_t envsize = 0;
        errcode = getenv_s(&envsize, NULL, 0, name);
        if(errcode || envsize) return errcode;
    }
    return _putenv_s(name, value);
}
#endif

void init_miniaudio(void) {

    /*
    Currently, no specific init is needed. For older version of miniaudio, we had this:

    This is needed to avoid a huge multi second delay when using PulseAudio (without the minreq value patch)
    It seems to be related to the pa_buffer_attr->minreq value
    See https://freedesktop.org/software/pulseaudio/doxygen/structpa__buffer__attr.html#acdbe30979a50075479ee46c56cc724ee
    and https://github.com/pulseaudio/pulseaudio/blob/4e3a080d7699732be9c522be9a96d851f97fbf11/src/pulse/stream.c#L989

    setenv("PULSE_LATENCY_MSEC", "100", 0);
    */
}


/* Nothing more to do here; all the decoder source is in their own single source/include file */

void data_callback(ma_device* pDevice, void* pOutput, const void* pInput, ma_uint32 frameCount)
{
    ma_decoder* pDecoder = (ma_decoder*)pDevice->pUserData;
    if (pDecoder == NULL) {
        return;
    }

    ma_decoder_read_pcm_frames(pDecoder, pOutput, frameCount);

    (void)pInput;
}

int single_playback(int argc, char** argv)
{
    ma_result result;
    ma_decoder decoder;
    ma_device_config deviceConfig;
    ma_device device;

    if (argc < 2) {
        printf("No input file.\n");
        return -1;
    }

    result = ma_decoder_init_file(argv[1], NULL, &decoder);
    if (result != MA_SUCCESS) {
        return -2;
    }

    deviceConfig = ma_device_config_init(ma_device_type_playback);
    deviceConfig.playback.format   = decoder.outputFormat;
    deviceConfig.playback.channels = decoder.outputChannels;
    deviceConfig.sampleRate        = decoder.outputSampleRate;
    deviceConfig.dataCallback      = data_callback;
    deviceConfig.pUserData         = &decoder;

    if (ma_device_init(NULL, &deviceConfig, &device) != MA_SUCCESS) {
        printf("Failed to open playback device.\n");
        ma_decoder_uninit(&decoder);
        return -3;
    }

    if (ma_device_start(&device) != MA_SUCCESS) {
        printf("Failed to start playback device.\n");
        ma_device_uninit(&device);
        ma_decoder_uninit(&decoder);
        return -4;
    }

/*
    printf("Press Enter to quit...");
    getchar();
*/

    ma_device_uninit(&device);
    ma_decoder_uninit(&decoder);

    return 0;
}
