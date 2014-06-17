<?php
/* TORTILLA PHP */
/* version 1.3 */

$dir_content = 'content/';
$default_lang = 'de';
$default_page = 'home';
$default_extension = '.xml';

$dir_stylesheets = 'design/';
$default_xslt = $dir_stylesheets.'tortilla.xsl';
$default_css = $dir_stylesheets.'tortilla.css';

function getWebroot () {
  $servername = $_SERVER['SERVER_NAME'];
  switch ($servername) {
      case 'tortilla.elitepiraten.de':
          $webroot = 'http://tortilla.elitepiraten.de';
          break;
      case 'localhost':
          $webroot = 'http://localhost/tortilla';
          break;
      default:
          echo 'no configuration found for a server named '.$servername;
          exit;
  }
  return $webroot;
}

// no configuration needed below this point

function XMLContent ($xml_file,$xslt_file,$parameters) {
  $xml_content = NULL;
  $html_doctype = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" />';
  if (file_exists($xml_file)) {
    $xml = new DomDocument();
    $xml->load($xml_file);
    if(!$xml) {
      exit ("xml document error");
    }
    $xslt = new DomDocument();
    $xslt->load($xslt_file);
    if(!$xslt) {
      exit("xslt document error");
    }
    $xsltproc = new XsltProcessor();
    if(!$xsltproc) {
      exit ("xslt processor error");
    }
    $xsltproc->importStylesheet($xslt);
    if (!empty($parameters)) {
      //print_r($parameters);
      foreach ($parameters as $param_name => $param_value) {
        $xsltproc->setParameter('','GET_'.$param_name,$param_value);
      }
    }
    $xsltproc->setParameter('','WEBROOT',getWebroot());
    $xsltproc->setParameter('','CSS',$GLOBALS['default_css']);
    $xml_content = $xsltproc->transformToXml($xml);
  } else {
    exit ("file not found error: ".$xml_file);
  }
  return $html_doctype.$xml_content;
}

if (!empty($_GET['query'])) {
	$parameters = explode('/',$_GET['query']);
}
else {
	$parameters = array($default_content);
}

if ((!isset($parameters[0])) || (empty($parameters[0]))) {
	$parameters[0] = $default_lang;
}
if ((!isset($parameters[1])) || (empty($parameters[1]))) {
	$parameters[1] = $default_page;
}

$xml_file = $dir_content.$parameters[0].'/'.$parameters[1].$default_extension;

$xslt_file = $default_xslt;
$html_content = XMLContent ($xml_file,$xslt_file,$parameters);
echo $html_content;

?>
