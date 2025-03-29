VDP_WRITE_REGISTER = 0x80

output = "";
values = [1, 2, 1, 2, 1];
//values = [0, 1, 0, 1, 0];

for (var i = 0; i < 64; i++)
{
    text_height = values[0] + values[1] + values[2] + values[3] + values[4];
    half_margin = Math.round(((192/2) - (values[0] + values[1] + values[2]))/2);

    out = [
        (0xf1 | (5 << 1)), 0x2 | VDP_WRITE_REGISTER, half_margin, 0xa | VDP_WRITE_REGISTER,
        (0xf1 | (5 << 1)), 0x2 | VDP_WRITE_REGISTER, values[0], 0xa | VDP_WRITE_REGISTER,
        (0xf1 | (0 << 1)), 0x2 | VDP_WRITE_REGISTER, values[1], 0xa | VDP_WRITE_REGISTER,
        (0xf1 | (1 << 1)), 0x2 | VDP_WRITE_REGISTER, values[2], 0xa | VDP_WRITE_REGISTER,
        (0xf1 | (2 << 1)), 0x2 | VDP_WRITE_REGISTER, values[3], 0xa | VDP_WRITE_REGISTER,
        (0xf1 | (3 << 1)), 0x2 | VDP_WRITE_REGISTER, values[4], 0xa | VDP_WRITE_REGISTER,
        (0xf1 | (4 << 1)), 0x2 | VDP_WRITE_REGISTER, 255, 0xa | VDP_WRITE_REGISTER,
        (0xf1 | (5<< 1)), 0x2 | VDP_WRITE_REGISTER, 255, 0xa | VDP_WRITE_REGISTER,
    ];

    output += ".db " + out.join(", ") + "\n";

    switch (i % 4)
    {
        case 0:
            values[1] += 1;
            break;

        case 1:
            values[0] += 1;
            break;

        case 2:
            values[3] += 1;
            break;

        case 3:
            values[2] += 1;
            values[4] += 1;
            break;
    }
}

console.log(output);
