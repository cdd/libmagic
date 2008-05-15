#include "ruby.h"
#include <magic.h>

VALUE rb_cMagic;
VALUE magic_file_mime_type(VALUE instance, VALUE str);
VALUE magic_string_mime_type(VALUE instance, VALUE str);
VALUE process_result(magic_t cookie, const char *mime_type);
magic_t load_cookie();

magic_t load_cookie()
{
    magic_t cookie = magic_open(MAGIC_MIME | MAGIC_ERROR);
    magic_load(cookie, NULL);
    return cookie;
}

VALUE process_result(magic_t cookie, const char *mime_type)
{
    if (mime_type == NULL) {
        rb_raise(rb_eRuntimeError, magic_error(cookie));
    } else {
        return rb_str_new(mime_type, strlen(mime_type));
    }
}

VALUE magic_file_mime_type(VALUE instance, VALUE str) 
{
    const char *filename = RSTRING(str)->ptr;

    magic_t cookie = load_cookie();
    const char *mime_type = magic_file(cookie, filename);
    return process_result(cookie, mime_type);
}

VALUE magic_string_mime_type(VALUE instance, VALUE str)
{
    const char *c_str = RSTRING(str)->ptr;
    
    magic_t cookie = load_cookie();
    const char *mime_type = magic_buffer(cookie, c_str, strlen(c_str));
    return process_result(cookie, mime_type);
}

void Init_libmagic_wrapper (void) {
    rb_cMagic = rb_define_class("Magic", rb_cObject);
    rb_define_singleton_method(rb_cMagic, "file_mime_type", magic_file_mime_type, 1);
    rb_define_singleton_method(rb_cMagic, "string_mime_type", magic_string_mime_type, 1);
}
