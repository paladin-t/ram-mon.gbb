#if defined __SDCC
#   include <gbdk/platform.h>
#else /* __SDCC */
#   error "Not implemented."
#endif /* __SDCC */

#include "utils/exception.h"
#include "utils/utils.h"

#include "vm.h"
#include "vm_device.h"
#include "vm_game.h"

extern const UINT8 BOOTSTRAP[];
BANKREF_EXTERN(BOOTSTRAP)

#define WAVE_RAM_SIZE 16u
static UINT8 wave_ram_save[WAVE_RAM_SIZE];

const UINT8 WAVE_RAM_POCKET_DMG[WAVE_RAM_SIZE] = {
    0x70, 0xB0, 0xFC, 0xD8,
    0x88, 0xD3, 0x12, 0x60,
    0x62, 0x77, 0x3B, 0xFE,
    0x6D, 0xA9, 0x76, 0xDB
};
const UINT8 WAVE_RAM_POCKET_CGB[WAVE_RAM_SIZE] = {
    0x24, 0xAE, 0xE0, 0x8D,
    0x80, 0xF6, 0x79, 0x2D,
    0x09, 0xFF, 0x41, 0xBD,
    0xC0, 0x76, 0x46, 0xDB
};

STATIC BOOLEAN check_fingerprint(UINT8 * p_tocheck, const UINT8 * p_reference, UINT8 bufsize) {
    for (UINT8 c = 0u; c < bufsize; ++c) {
        if (*p_tocheck != *p_reference)
            return FALSE;

        ++p_tocheck;
        ++p_reference;
    }

    return TRUE;
}

STATIC void save_wave_ram(void) {
    NR52_REG = 0x80;
    for (UINT8 c = 0u; c < WAVE_RAM_SIZE; ++c)
        wave_ram_save[c] = AUD3WAVE[c];

    waitpadup();
}

STATIC BOOLEAN is_it_pocket(void) {
    save_wave_ram();
    if (check_fingerprint(wave_ram_save, WAVE_RAM_POCKET_DMG, WAVE_RAM_SIZE))
        return TRUE;
    else if (check_fingerprint(wave_ram_save, WAVE_RAM_POCKET_CGB, WAVE_RAM_SIZE))
        return TRUE;
    else
        return FALSE;
}

#ifdef ANALOGUEPOCKET
#   define STATF_PPU_MODE_3 0b11000000
#else
#   define STATF_PPU_MODE_3 0b00000011
#endif

STATIC BOOLEAN is_it_pocket_gbc(void) {
    BOOLEAN result = FALSE;

    while (rLY != 141u) ;
    while (rLY != 142u) ;
    while ((rSTAT & STATF_LCD) != STATF_PPU_MODE_3) ;
    rLCDC = LCDCF_OFF;
    rBCPS = 0u;
    rBCPD = 0u;
    volatile UINT8 read_pal = rBCPD;
    rBCPD = 0xFFu;
    rLCDC = LCDCF_ON;
    if (read_pal != 0u)
        result = TRUE;

    return result;
}

inline void setup(void) {
    script_runner_init(TRUE);
    script_execute(BANK(BOOTSTRAP), BOOTSTRAP, NULL, 0);
}

inline void update(void) {
    while (TRUE) {
        switch (script_runner_update()) {
        case RUNNER_DONE: // Fall through.
        case RUNNER_IDLE:
            if (FEATURE_AUTO_UPDATE_ENABLED)
                game_update();

            vsync();

            break;
        case RUNNER_BUSY:
            break;
#if VM_EXCEPTION_ENABLED
        case RUNNER_EXCEPTION:
            exception_handle_vm_raised();

            return;
#endif /* VM_EXCEPTION_ENABLED */
        default:
            break;
        }
    }
}

void main(void) {
    BOOLEAN is_ap = FALSE; // The AP detection algorithm is ported from https://github.com/bbbbbr/is_it_analoguepocket.
    if (_cpu == CGB_TYPE) {
        if (*(uint8_t*)0x0143 != 0x00u)
            is_ap = is_it_pocket_gbc();
    } else {
        is_ap = is_it_pocket();
    }
    if (is_ap) device_type |= DEVICE_TYPE_AP;

    setup();
    update();
}
