Objectify
=========

This is a plugin for seamless storage and retrieval of objects/blob as binary datum without worrying about loading or making them storing them the ActiveRecord safe way.


__When do you need it?__ - For using non-model instances as attributes for an ActiveRecord objects


__How does it differ from Active Record's serialize?__ - Objectify can handle *nested* objects. The "serialize" approach
will return only an unserialized *YAML::OBJECT* rather than the object of the actual class.


__What does it do?__

+	Handles safe storage of objects(to any depth) as binary data in the database
+	Reloads the object to it's true form upon instantiation


Installation
------------

Place the entire plugin in the vendor/plugins folder of your rails app or execute

	  rails plugin install git://github.com/invoscape/objectify.git

Usage
-----

Let us say you have an attribute which is an instance of a non-model class. Just declare

	class MyClass < ActiveRecord::Base
	    object_attribute :my_attribute, TheClass
	end
	
Now, whenever an object of 'MyClass' is created, the attribute 'my_attribute' will be an instance of 'TheClass'. You can
continue using it like any instance. When saved, it is saved in it's binary form.

In the above example note that the plugin will assume the name of the column in the table corresponding to the 'my_attribute'
as 'my_attribute_object'. However, you can specify a different name for the column as the third argument

	object_attribute :my_attribute, TheClass, 'different_named_column_for_my_attribute'



__Home page__ - [invoscape.com/open_source#objectify](http://www.invoscape.com/open_source#objectify)

__Want to contribute ?__ - Drop in a mail to opensource(at)invoscape(dot)com

Please do report any issues you face - [issues](https://github.com/invoscape/objectify/issues)

Copyright &copy; [Invoscape Technologies Pvt. Ltd.](http://www.invoscape.com), released under the MIT license