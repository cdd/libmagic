#include "ruby.h"
#include <magic.h>

VALUE rb_cMagic;
VALUE magic_file_mime_type(VALUE instance, VALUE str);

VALUE magic_file_mime_type(VALUE instance, VALUE str) 
{
    const char *filename = RSTRING(str)->ptr;

    magic_t cookie = magic_open(MAGIC_MIME | MAGIC_ERROR);
    magic_load(cookie, NULL);
    const char *mime_type = magic_file(cookie, filename);

    if (mime_type == NULL) {
        rb_raise(rb_eRuntimeError, magic_error(cookie));
    } else {
        return rb_str_new(mime_type, strlen(mime_type));
    }
}

void Init_libmagic_wrapper (void) {
    rb_cMagic = rb_define_class("Magic", rb_cObject);
    rb_define_singleton_method(rb_cMagic, "file_mime_type", magic_file_mime_type, 1);
}
