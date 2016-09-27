*** Settings ***
Suite Setup     DMARC Setup
Suite Teardown  Generic Teardown
Library         ${TESTDIR}/lib/rspamd.py
Resource        ${TESTDIR}/lib/rspamd.robot
Variables       ${TESTDIR}/lib/vars.py

*** Variables ***
${CONFIG}        ${TESTDIR}/configs/plugins.conf
${RSPAMD_SCOPE}  Suite
${URL_TLD}       ${TESTDIR}/../../contrib/publicsuffix/effective_tld_names.dat

*** Test Cases ***
DMARC NONE PASS DKIM
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/pass_none.eml
  Check Rspamc  ${result}  DMARC_POLICY_ALLOW

DMARC NONE PASS SPF
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/fail_none.eml
  ...  -i  212.47.245.199  --from  foo@rspamd.tk
  Check Rspamc  ${result}  DMARC_POLICY_ALLOW

DMARC NONE FAIL
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/fail_none.eml
  Check Rspamc  ${result}  DMARC_POLICY_SOFTFAIL

DMARC REJECT FAIL
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/fail_reject.eml
  Check Rspamc  ${result}  DMARC_POLICY_REJECT

DMARC QUARANTINE FAIL
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/fail_quarantine.eml
  Check Rspamc  ${result}  DMARC_POLICY_QUARANTINE

DMARC SP NONE FAIL
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/subdomain_fail_none.eml
  Check Rspamc  ${result}  DMARC_POLICY_SOFTFAIL

DMARC SP REJECT FAIL
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/subdomain_fail_reject.eml
  Check Rspamc  ${result}  DMARC_POLICY_REJECT

DMARC SP QUARANTINE FAIL
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/subdomain_fail_quarantine.eml
  Check Rspamc  ${result}  DMARC_POLICY_QUARANTINE

DMARC SUBDOMAIN FAIL DKIM STRICT ALIGNMENT
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/onsubdomain_fail_alignment.eml
  Check Rspamc  ${result}  DMARC_POLICY_REJECT

DMARC SUBDOMAIN PASS DKIM RELAXED ALIGNMENT
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/onsubdomain_pass_relaxed.eml
  Check Rspamc  ${result}  DMARC_POLICY_ALLOW

DMARC SUBDOMAIN PASS SPF STRICT ALIGNMENT
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/onsubdomain_fail_alignment.eml
  ...  -i  37.48.67.26  --from  foo@yo.mom.za.org
  Check Rspamc  ${result}  DMARC_POLICY_ALLOW

DMARC SUBDOMAIN FAIL SPF STRICT ALIGNMENT
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/onsubdomain_fail_alignment.eml
  ...  -i  37.48.67.26  --from  foo@mom.za.org
  Check Rspamc  ${result}  DMARC_POLICY_REJECT

DMARC SUBDOMAIN PASS SPF RELAXED ALIGNMENT
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/onsubdomain_fail.eml
  ...  -i  37.48.67.26  --from  foo@mom.za.org
  Check Rspamc  ${result}  DMARC_POLICY_ALLOW

DKIM PERMFAIL NXDOMAIN
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/bad_dkim2.eml
  ...  -i  37.48.67.26
  Check Rspamc  ${result}  R_DKIM_PERMFAIL

DKIM PERMFAIL BAD RECORD
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/bad_dkim1.eml
  ...  -i  37.48.67.26
  Check Rspamc  ${result}  R_DKIM_PERMFAIL

SPF DNSFAIL UNRESOLVEABLE INCLUDE
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/bad_dkim1.eml
  ...  -i  37.48.67.26  -F  x@openarena.za.net
  Check Rspamc  ${result}  R_SPF_DNSFAIL

SPF DNSFAIL FAILED INCLUDE
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/bad_dkim1.eml
  ...  -i  8.8.8.8  -F  x@fail2.org.org.za
  Check Rspamc  ${result}  R_SPF_DNSFAIL

SPF ALLOW UNRESOLVEABLE INCLUDE
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/bad_dkim1.eml
  ...  -i  8.8.8.8  -F  x@openarena.za.net
  Check Rspamc  ${result}  R_SPF_ALLOW

SPF ALLOW FAILED INCLUDE
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/bad_dkim1.eml
  ...  -i  8.8.4.4  -F  x@fail2.org.org.za
  Check Rspamc  ${result}  R_SPF_ALLOW

SPF NA NA
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/bad_dkim1.eml
  ...  -i  8.8.8.8  -F  x@za
  Check Rspamc  ${result}  R_SPF_NA

SPF NA NOREC
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/bad_dkim1.eml
  ...  -i  8.8.8.8  -F  x@co.za
  Check Rspamc  ${result}  R_SPF_NA

SPF NA NXDOMAIN
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/bad_dkim1.eml
  ...  -i  8.8.8.8  -F  x@zzzzaaaa
  Check Rspamc  ${result}  R_SPF_NA

SPF PERMFAIL UNRESOLVEABLE REDIRECT
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/bad_dkim1.eml
  ...  -i  8.8.8.8  -F  x@cacophony.za.org
  Check Rspamc  ${result}  R_SPF_PERMFAIL

SPF DNSFAIL FAILED REDIRECT
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/bad_dkim1.eml
  ...  -i  8.8.8.8  -F  x@fail1.org.org.za
  Check Rspamc  ${result}  R_SPF_DNSFAIL

SPF PERMFAIL
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/bad_dkim1.eml
  ...  -i  8.8.8.8  -F  x@xzghgh.za.org
  Check Rspamc  ${result}  R_SPF_PERMFAIL

SPF FAIL
  ${result} =  Scan Message With Rspamc  ${TESTDIR}/messages/dmarc/bad_dkim1.eml
  ...  -i  8.8.8.8  -F  x@example.net
  Check Rspamc  ${result}  R_SPF_FAIL

*** Keywords ***
DMARC Setup
  ${PLUGIN_CONFIG} =  Get File  ${TESTDIR}/configs/dmarc.conf
  Set Suite Variable  ${PLUGIN_CONFIG}
  Generic Setup  PLUGIN_CONFIG
