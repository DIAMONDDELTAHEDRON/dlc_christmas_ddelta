extern vec2 position;
extern vec2 texture_size;
extern vec2 radius;
extern vec4 draw_color;
extern float strength;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    float x_max_dist = radius.x / texture_size.x;
    float y_max_dist = radius.y / texture_size.y;

    float x_center = position.x / texture_size.x;
    float y_center = position.y / texture_size.y;

    float dist = sqrt(pow(min(abs(texture_coords.x - x_center) / x_max_dist, 1.0), 2.0) +
                      pow(min(abs(texture_coords.y - y_center) / y_max_dist, 1.0), 2.0));
    // Smooth Gradient with Accurate Light Falloff (TM)
    float alpha = strength * (1 / pow(9 * clamp(dist, 0, 1) + 1, 2) - 0.01) / 0.99;

    return vec4(draw_color.r, draw_color.g, draw_color.b, draw_color.a * alpha);
}