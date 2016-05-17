#ifndef __EMULATE_H__
#define __EMULATE_H__

#include <stddef.h>
#include <stdint.h>
#include <functional>
#include <memory>

#include "Memory.h"
#include "ModRM.h"

static inline phys_addr get_phys_addr(uint16_t segment,
                                      uint16_t displacement)
{
    return (static_cast<uint32_t>(segment) << 4) + displacement;
}

class EmulatorPimpl;
class Memory;
class RegisterFile;

class Emulator {
public:
    Emulator(RegisterFile *registers);
    virtual ~Emulator();
    size_t emulate();
    void set_memory(Memory *mem);
    void set_io(Memory *io);
    bool has_trapped() const;
    void reset();

private:
    std::unique_ptr<EmulatorPimpl> pimpl;
};

#endif /* __EMULATE_H__ */
