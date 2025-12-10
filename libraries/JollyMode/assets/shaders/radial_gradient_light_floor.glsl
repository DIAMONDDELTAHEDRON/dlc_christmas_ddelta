extern vec2 position;
extern vec2 texture_size;
extern vec2 radius;
extern vec4 draw_color;
extern float strength;
extern vec4 range;

float range_map(float val, float min_a, float max_a, float min_b, float max_b) {
    if (min_a > max_a) {
        min_a, max_a = max_a, min_a;
        min_b, max_b = max_b, min_b;
    }
    float t = (val - min_a) / (max_a - min_a);
    return min_b + (max_b - min_b) * t;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    float x_max_dist = radius.x / texture_size.x;
    float y_max_dist = radius.y / texture_size.y;

    float x_center = position.x / texture_size.x;
    float y_center = position.y / texture_size.y;

    float dist = sqrt(pow(min(abs(texture_coords.x - x_center) / x_max_dist, 1.0), 2.0) +
                      pow(min(abs(texture_coords.y - y_center) / y_max_dist, 1.0), 2.0));
    dist = range_map(dist, range[0], range[1], range[2], range[3]);
    // Smooth Gradient with Accurate Light Falloff (TM)
    float alpha = strength * (1 / pow(9 * clamp(dist, 0, 1) + 1, 2) - 0.01) / 0.99;
    // alpha = range_map(alpha, range[0], range[1], range[2], range[3]);
    
    return vec4(draw_color.rgb, draw_color.a * alpha);
}