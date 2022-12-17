---
title: "Autowired Traits in Symfony"
date: 2017-10-07
tags: ["how-to", "tools", "code"]
type: post
---

This is something that I think is pretty slick in Symfony.  With 3.3, Symfony
introduced the idea of [autowired
services](https://symfony.com/doc/current/service_container/autowiring.html).
Basically, you just put a type hint for what you need and the container injects
the correct service as if by magic. You can take advantage of this in some more
unusual places that aren’t immediately apparent after reading the documentation.

In my case, I had a controller trait that provides some common functions but it
needs to interface with some services to do this.  The first way I thought to do
things was to use the method injection on all the controller actions, but this
gets really messy really quick.  In this case, all of our controller actions
would have to have all of the services this traits needs, which introduces quite
a bit of repetition and makes the trait and controllers more coupled.

Since your controllers are really services now (see below), you can take
advantage of injection via setters (mentioned
[here](https://symfony.com/doc/current/service_container/autowiring.html#autowiring-other-methods-e-g-setters)).
Even in your traits, the container follows the annotations, so you can have them
autowired too.  All you have to do is create a setter function and add the
`@required` annotation.  This way, your controller class is ignorant of the
inner workings of your trait, making things a lot more clear.

Here’s an example, I have a trait that acts as a shortcut converting data coming
from the request into an object from our database.  Our trait looks like this:

```php
<?php
namespace CoreBundle\Traits;

use StorehouseBundle\Entity\Project;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\HttpFoundation\Request;
use Doctrine\ORM\EntityManagerInterface;

/*
 * The Storehouse - Project Storage for Big Ideas
 *
 * This file is part of The Storehouse. Copyright 2017 .
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
trait BrowserTrait
{

    /**
     * The project that we're working with for this request.
     *
     * @var Project
     */
    protected $project;

    /**
     * Entity manager to use to look up projects.
     *
     * @var EntityManagerInterface
     */
    protected $entityManager;

    /**
     * @required
     * @param EntityManagerInterface $dispatcher
     */
    public function setEntityManager(EntityManagerInterface $entityManager)
    {
        $this->entityManager = $entityManager;
    }

    /**
     * Get a project entity based on the URL string component.
     */
    protected function getProject(Request $request)
    {
        /* Load our project from the name in the request */
        $repo = $this->entityManager->getRepository('StorehouseBundle:Project');
        $project = $repo->findOneByName($request->get('project'));

        if (is_null($project)) {
            throw new NotFoundHttpException();
        }
        $this->project = $project;
    }
}
```

Now all the controller actions have to do is call the `getProject` function with
the request for that specific action, and the leg work of getting the
EntityManager is taken care of automatically.  Since this is a very common
action in Storehouse controller actions, this trait prevents repetitions code.

In this example, we’re doing this for a trait for use with controller classes,
but you can in theory do this if you have a trait that is shared between
services.  Using the same annotation, the container injects the service and lets
you define dependencies in both the constructor and in setter functions.

## Gotcha: Controllers as Services

Symfony 3.3 defines your controllers as services and autowires them by default.
This is the same process that makes the [method
injection](https://symfony.com/doc/current/controller.html#controller-accessing-services)
work, but if your project started before Symfony 3.3, this isn’t setup by
default.  Setting up your controllers as services isn’t in the scope of this
post, but it is imperative that it is setup for this method to work.
