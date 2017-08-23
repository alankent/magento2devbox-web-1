<?php
/**
 * Copyright © 2013-2017 Magento, Inc. All rights reserved.
 * See COPYING.txt for license details.
 */
namespace MagentoDevBox\Command\Options;

/**
 * Container for web server options
 */
class WebServer extends AbstractOptions
{
    const HOST = 'webserver-host';
    const PORT = 'webserver-port';

    /**
     * {@inheritdoc}
     */
    protected static function getOptions()
    {
        return [
            static::HOST => [
                'default' => 'web',
                'description' => 'Web server host.',
                'question' => 'Please enter web server host %default%'
            ],
            static::PORT => [
                'default' => '80',
                'description' => 'Web server port.',
                'question' => 'Please enter web server port %default%'
            ]
        ];
    }
}
