#include <stdio.h>
#include <stdlib.h>
#include "json.h"

int main(int argc,char *argv[])
{
	json_object *new_obj;
	char *str="{\"Lon\":\"121.42205\",\"Lat\":\"31.32118\"}";
	new_obj=json_tokener_parse(str);
	printf("%s\n",json_object_to_json_string(new_obj));
	json_object_put(new_obj);
	return 0;
}
