<?php
/**
 * Copyright © 2013-2017 Magento, Inc. All rights reserved.
 * See COPYING.txt for license details.
 */
namespace MagentoDevBox\Command\Pool;

use MagentoDevBox\Command\AbstractCommand;
use MagentoDevBox\Command\Options\Magento as MagentoOptions;
use MagentoDevBox\Command\Options\Db as DbOptions;
use MagentoDevBox\Command\Options\ElasticSearch as ElasticSearchOptions;
use MagentoDevBox\Library\Db;
use MagentoDevBox\Library\ModuleExistence;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

/**
 * Command for Magento final steps
 */
class MagentoFinalize extends AbstractCommand
{
    /**
     * Configuration scope in the DB
     *
     * @var string
     */
    private $dbConfigScope = 'default';

    /**
     * Configuration scope id in the DB
     *
     * @var integer
     */
    private $dbConfigScopeId = 0;

    /**
     * Apache configuration file
     *
     * @var string
     */
    private $apacheConfigFile = '/etc/apache2/sites-enabled/apache-default.conf';

    /**
     * {@inheritdoc}
     */
    protected function configure()
    {
        $this->setName('magento:finalize')
            ->setDescription('Prepare Magento for usage')
            ->setHelp('This command allows you to perform final steps for Magento usage.');

        parent::configure();
    }

    /**
     * {@inheritdoc}
     */
    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $magentoPath = $input->getOption(MagentoOptions::PATH);
        $this->executeCommands(sprintf('cd %s && magento deploy:mode:set developer', $magentoPath), $output);

        if ($this->requestOption(MagentoOptions::DI_COMPILE, $input, $output)) {
            $this->executeCommands(sprintf('cd %s && magento setup:di:compile', $magentoPath), $output);
        }

        if ($this->requestOption(MagentoOptions::STATIC_CONTENTS_DEPLOY, $input, $output)) {
            $this->executeCommands(
                sprintf('cd %s && magento setup:static-content:deploy', $magentoPath),
                $output
            );
        } elseif ($this->requestOption(MagentoOptions::GRUNT_COMPILE, $input, $output)) {
            $this->executeCommands(
                [
                    sprintf(
                        'cd %s && cp Gruntfile.js.sample Gruntfile.js && cp package.json.sample package.json',
                        $magentoPath
                    ),
                    sprintf('cd %s && npm install && grunt refresh --force', $magentoPath)
                ],
                $output
            );
        }

        if ($this->requestOption(MagentoOptions::CRON_RUN, $input, $output)) {
            $crontab = implode(
                "\n",
                [
                    sprintf(
                        '* * * * * /usr/local/bin/php %s/bin/magento cron:run | grep -v "Ran jobs by schedule"'
                        . ' >> %s/var/log/magento.cron.log',
                        $magentoPath,
                        $magentoPath
                    ),
                    sprintf(
                        '* * * * * /usr/local/bin/php %s/update/cron.php >> %s/var/log/update.cron.log',
                        $magentoPath,
                        $magentoPath
                    ),
                    sprintf(
                        '* * * * * /usr/local/bin/php %s/bin/magento setup:cron:run >> %s/var/log/setup.cron.log',
                        $magentoPath,
                        $magentoPath
                    )
                ]
            );
            file_put_contents("/home/magento2/crontab.sample", $crontab . "\n");
            $this->executeCommands(['crontab /home/magento2/crontab.sample', 'crontab -l'], $output);
        }

        if (ModuleExistence::isModuleExists($input->getOption(MagentoOptions::PATH), ElasticSearchOptions::ELASTIC_MODULE_NAME)) {
            $this->executeCommands(sprintf('cd %s && magento indexer:reindex', $magentoPath), $output);
        }

        $this->executeCommands(sprintf('cd %s && magento cache:clean', $magentoPath), $output);

        $enableSyncMarker = $input->getOption(MagentoOptions::ENABLE_SYNC_MARKER);

        if ((boolean)$enableSyncMarker) {
            $statePath = $input->getOption(MagentoOptions::STATE_PATH);
            $syncMarkerPath =  $statePath . '/' . $enableSyncMarker;

            if (!file_exists($syncMarkerPath)) {
                $this->executeCommands(sprintf('touch %s', $syncMarkerPath), $output);
            }
        }

        chmod(sprintf('%s/bin/magento', $magentoPath), 0750);
    }

    /**
     * {@inheritdoc}
     */
    public function getOptionsConfig()
    {
        return [
            MagentoOptions::PATH => MagentoOptions::get(MagentoOptions::PATH),
            MagentoOptions::STATIC_CONTENTS_DEPLOY => MagentoOptions::get(MagentoOptions::STATIC_CONTENTS_DEPLOY),
            MagentoOptions::GRUNT_COMPILE => MagentoOptions::get(MagentoOptions::GRUNT_COMPILE),
            MagentoOptions::DI_COMPILE => MagentoOptions::get(MagentoOptions::DI_COMPILE),
            MagentoOptions::CRON_RUN => MagentoOptions::get(MagentoOptions::CRON_RUN),
            DbOptions::HOST => DbOptions::get(DbOptions::HOST),
            DbOptions::USER => DbOptions::get(DbOptions::USER),
            DbOptions::PASSWORD => DbOptions::get(DbOptions::PASSWORD),
            DbOptions::NAME => DbOptions::get(DbOptions::NAME),
            MagentoOptions::STATE_PATH => MagentoOptions::get(MagentoOptions::STATE_PATH),
            MagentoOptions::ENABLE_SYNC_MARKER => MagentoOptions::get(MagentoOptions::ENABLE_SYNC_MARKER)
        ];
    }

    /**
     * Update apache config
     *
     * @param $url string
     * @return void
     */
    private function updateApacheConfig($url)
    {
        $port = parse_url($url, PHP_URL_PORT);
        $this->executeCommands(
            [
                sprintf('sudo sed -i -e \'s/\Listen[[:space:]]*[[:digit:]]*//g\' %s', $this->apacheConfigFile),
                sprintf('sudo bash -c "echo -e \'\nListen %s\n\' >> %s"', $port, $this->apacheConfigFile),
            ]
        );
    }
}
