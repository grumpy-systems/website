---
title: "Doctrine Entity Testing"
date: 2016-09-22
tags: ["tools","code"]
type: post
---

One of the things I’m working towards with Storehouse is 100% code coverage.
This really exposed the need to have a more streamlined way of testing Doctrine
entities, since they have to have a lot of getProperty and setProperty
functions.  My solution was to write a simple test case that runs through
properties of an object and checks each one.

_Update: It’s only been a month and I’ve already found a better way of doing
things.  The idea and needs are the same, but is implemented using a bit more
clever solution._

These functions are really quite simple, the setters take a single argument and
return the object.  The getters take no arguments and return the value.  My
tests were equally simple: generate a test value that makes sense for the
property, set it and retrieve it, checking that we got the same thing back.  The
problem with this was repetition, since some of my entities have numerous get
and set functions, there were numerous test functions.

The test case is pretty simple: only a few lines.  This reduces the tests to be
simple themselves.

Here’s the framework test:

```php
<?php

namespace StorehouseBundle\Tests\Cases;

/*
 * The Storehouse - Project Storage for Big Ideas
 *
 * This file is part of The Storehouse. Copyright 2016 .
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
class EntityTestCase extends \PHPUnit_Framework_TestCase {

    /**
     * Iterate through an array of getters and setters for an entity and check
     * each one.
     *
     * @param array $values
     *            An array of properties and test values for each property
     * @param mixed $object
     *            The object we're testing
     */
    protected function checkProperties($values, $object) {
        foreach ( $values as $property => $value ) {
            /* These are function names we'll try to run */
            $setFunctions = array (
                    $property,
                    'set' . ucfirst ( $property )
            );
            $getFunctions = array (
                    $property,
                    'get' . ucfirst ( $property ),
                    'is' . ucFirst ( $property )
            );

            $foundSetter = false;
            $foundGetter = false;

            foreach ( $setFunctions as $function ) {
                if (method_exists ( $object, $function )) {
                    $setResult = $object->{$function} ( $value );
                    $foundSetter = true;
                    break;
                }
            }

            foreach ( $getFunctions as $function ) {
                if (method_exists ( $object, $function )) {
                    $getResult = $object->{$function} ( $value );
                    $foundGetter = true;
                    break;
                }
            }

            $this->assertTrue ( $foundSetter,
                    sprintf ( 'Did not find setter function for property %s',
                            $property ) );
            $this->assertTrue ( $foundGetter,
                    sprintf ( 'Did not find getter function for property %s',
                            $property ) );

            $this->assertInstanceOf ( get_class ( $object ), $setResult,
                    sprintf ( 'Test for setting property %s failed.',
                            $property ) );
            $this->assertEquals ( $value, $getResult,
                    sprintf ( 'Test for getting property %s failed.',
                            $property ) );
        }
    }
}
?>
```

And here’s an example of using it:

```php
<?php

namespace StorehouseBundle\Tests\Entity\Billing\Invoice;

use Faker\Factory;
use Faker\Generator;
use StorehouseBundle\Entity\Billing\Invoice\Discount;
use StorehouseBundle\Entity\Billing\Invoice\Invoice;
use StorehouseBundle\Tests\Cases\EntityTestCase;

/*
 * The Storehouse - Project Storage for Big Ideas
 *
 * This file is part of The Storehouse. Copyright 2016 .
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
class AbstractInvoiceItemTest extends EntityTestCase {
    /**
     * Discount object we'll be testing.
     *
     * @var Discount
     */
    protected $discount;

    /**
     * Faker to use when generating strings
     *
     * @var Generator
     */
    protected $faker;

    public function setUp() {
        $this->discount = new Discount ();
        $this->faker = Factory::create ();
    }

    /**
     * @covers StorehouseBundle\Entity\Billing\Invoice\AbstractInvoiceItem::setId
     * @covers StorehouseBundle\Entity\Billing\Invoice\AbstractInvoiceItem::getId
     * @covers StorehouseBundle\Entity\Billing\Invoice\AbstractInvoiceItem::setInvoice
     * @covers StorehouseBundle\Entity\Billing\Invoice\AbstractInvoiceItem::getInvoice
     * @covers StorehouseBundle\Entity\Billing\Invoice\AbstractInvoiceItem::setTotal
     * @covers StorehouseBundle\Entity\Billing\Invoice\AbstractInvoiceItem::getTotal
     */
    public function testGettersAndSetters() {
        $values = array(
                'id' => $this->faker->numberBetween(),
                'invoice' => new Invoice(),
                'total' => $this->faker->numberBetween()
        );
        $this->checkProperties($values, $this->discount);
    }
}
?>
```

Basically, we just extends our new framework test case and setup our test like
normal.  The checkProperties function expects two arguments: an array of
properties as keys and test values and the object that we’ll test against.  The
function takes care of prepending set, get, and is to the property name (ie,
invoice converts to getInvoice), which follows the default Doctrine scheme.

This way, your test case can be boiled down to just a few tests that become less
repetitive, which I’ve learned to be very important on the road to 100%
coverage.

## Limitations and Caveats

I really designed this class to do the most basic get and set functions, so
anything that doesn’t store and return the exact result isn’t covered here.  As
well, anything with array collections isn’t covered by this.  This doesn’t mean
you can’t test these: you just have to write the tests by hand like before.
