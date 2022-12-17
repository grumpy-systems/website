---
title: "Doctrine Entity Testing 2.0"
date: 2016-10-21
tags: ["tools","code"]
---

About a month ago, I shared a method for testing doctrine entities.  This came
about after my push to get 100% code coverage on The Storehouse.  I’ve already
found a new and better way of doing this that gives you a bit more flexibility.

This new method does the exact same thing: test getters and setters for doctrine
entites.  The difference here is that I used a trait rather than a class.  This
is a bit nicer for a few reasons:

* **You aren’t bound to extending the EntityTestCase class.**  In my case this
  wasn’t an issue but it could be if you need to use both the helper function
  and use some more specialized test suite.  Since this particular test case was
  just testing getters and setters, they all extended
  PHPUnit_Framework_TestCase.  I’m already thinking of a few other repetitive
  tests that can be migrated to helper traits to make the code less repetitive.

* **You can make use of PHPUnit’s @dataProvider.**  This doesn’t sound like a
  huge deal but it is really nice.  This lets you run your tests, and get more
  specific errors on failure as well as continuing to test other properties if
  one fails.  This gives your tests a much more accurate picture as to what is
  failing, since everything is checked even with a previous failure.  This is
  really what the data providers in PHPUnit are for, since we essentially just
  want to run the same test function over multiple iterations.

Traits are a pretty cool feature of PHP that I don’t see that often.  In this
case, creating reusable functions to aid in testing were a perfect fit of this
feature of PHP.  The updated trait and an example test case are below.

```php
<?php

namespace StorehouseBundle\Tests\Traits;

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
/**
 * Helper functions to see check object properties.
 *
 * @author  
 * @copyright 2016 
 * @license GNU AGPL - See README for details
 *
 */
trait PropertyChecker {

    /**
     * @dataProvider getProperties
     *
     * @param string $property
     *            The name of the property to check.
     * @param string $value
     *            The test value we'll pass into and check for return of.
     * @param mixed $object
     *            Object that we'll test against.
     */
    public function testProperty($property, $value, $object) {
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
                sprintf ( 'Test for setting property %s failed.', $property ) );
        $this->assertEquals ( $value, $getResult,
                sprintf ( 'Test for getting property %s failed.', $property ) );
    }
}

?>
```

```php
<?php

namespace StorehouseBundle\Tests\Entity\Billing\Invoice;

use Faker\Factory;
use StorehouseBundle\Entity\Billing\Invoice\Invoice;
use StorehouseBundle\Tests\Fixtures\UserFixture;
use StorehouseBundle\Entity\Billing\Invoice\ProjectCharges;
use Doctrine\Common\Collections\ArrayCollection;
use StorehouseBundle\Entity\Billing\Invoice\Discount;
use StorehouseBundle\Tests\Cases\EntityTestCase;
use StorehouseBundle\Tests\Traits\PropertyChecker;

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
/**
 * @covers StorehouseBundle\Entity\Billing\Invoice\Invoice
 *
 * @author  
 * @copyright 2016 
 * @license GNU AGPL - See README for details
 *
 */
class InvoiceTest extends \PHPUnit_Framework_TestCase {

    use PropertyChecker;

    /**
     * Get properties to check.
     *
     * @return array
     */
    public function getProperties() {
        $faker = Factory::create ();
        $invoice = new Invoice ();

        return array (
                array (
                        'preDiscount',
                        $faker->numberBetween ( 1, 500 ),
                        $invoice
                ),
                array (
                        'subTotal',
                        $faker->numberBetween ( 1, 500 ),
                        $invoice
                ),
                array (
                        'tax',
                        $faker->numberBetween ( 1, 500 ),
                        $invoice
                ),
                array (
                        'discountAmount',
                        $faker->numberBetween ( 1, 500 ),
                        $invoice
                ),
                array (
                        'posted',
                        $faker->dateTimeThisYear,
                        $invoice
                ),
                array (
                        'charged',
                        $faker->dateTimeThisYear,
                        $invoice
                ),
                array (
                        'owner',
                        UserFixture::generateNewUser (),
                        $invoice
                )
        );
    }

    /**
     * Test get ID.
     */
    public function testId() {
        $invoice = new Invoice ();

        $this->assertNull ( $invoice->getId () );
    }

    /**
     * Test To String
     */
    public function testToString() {
        $invoice = new Invoice ();

        $this->assertEmpty ( $invoice->__toString () );
    }

    /**
     * Test constructer
     */
    public function testConstruct() {
        $invoice = new Invoice ();

        $this->assertInstanceOf ( Invoice::class, $invoice );
    }

    /**
     * Test set and get total.
     */
    public function testTotal() {
        $invoice = new Invoice ();

        $this->assertInstanceOf ( Invoice::class, $invoice->setTotal () );
        $this->assertInternalType ( 'numeric', $invoice->getTotal () );
    }

    /**
     * Test status with a valid status.
     */
    public function testValidStatus() {
        $invoice = new Invoice ();

        $status = array_rand ( Invoice::$statusCodes );

        $this->assertInstanceOf ( Invoice::class,
                $invoice->setStatus ( $status ) );
        $this->assertNotEmpty ( $invoice->getStatus () );
    }

    /**
     * Test status with an invalid status.
     */
    public function testInvalidStatus() {
        $invoice = new Invoice ();

        $this->assertInstanceOf ( Invoice::class,
                $invoice->setStatus ( 'not-a-key' ) );
        $this->assertNotEmpty ( $invoice->getStatus () );
    }

    /**
     * Test project methods.
     */
    public function testProject() {
        $invoice = new Invoice ();

        $project = new ProjectCharges ();
        $project->setTotal ( 5 );

        $this->assertInstanceOf ( Invoice::class,
                $invoice->addProject ( $project ) );
        $this->assertInstanceOf ( ArrayCollection::class,
                $invoice->getProjects () );
        $this->assertInstanceOf ( Invoice::class,
                $invoice->removeProject ( $project ) );
    }

    /**
     * Test discout methods.
     */
    public function testDiscount() {
        $invoice = new Invoice ();

        $discount = new Discount ();
        $discount->setTotal ( 5 );

        $this->assertInstanceOf ( Invoice::class,
                $invoice->addDiscount ( $discount ) );
        $this->assertInstanceOf ( ArrayCollection::class,
                $invoice->getDiscounts () );
        $this->assertInstanceOf ( Invoice::class,
                $invoice->removeDiscount ( $discount ) );
    }
}
?>
```
