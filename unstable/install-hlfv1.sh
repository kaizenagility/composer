ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.15.0
docker tag hyperledger/composer-playground:0.15.0 hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� �� Z �=�r��v�Ir3A��-U*�<��U#{l� ��<r\EK�$.�%�W��$D������'ܪ�@~#���|G~ ��n� Hq�L���y�lRݧO�^N�Y��uCi#3���a�PW���i8z=��h��8��H>�q�~��\�8��I\Lz�?��p�T�Lp,� <�Mx�Z�����J���j�[`C�`����-�����N��m���<�am��4S��&Nk����P���� ?0�(j�0m�%	@llr���o��!�B5��t{���/�3���~1��m�W^ �oX�u��oG����a��LƠX^�`$��t,���{���r����H7M#+#�D6)XܯT˙��b��m��B�n�EL���#�ŝ��~b��d�,�:Rl�i��P54��u��ZZ�LU���:�S��;���0����,
6.��v��Bl���ʶaR�H�� G���ƃWǣ�B͚Y��A�C�/f3���L<�����i9�FXo�]e+�(��%�t5DZ��$n����>)f�Bq��}�Q���:V7�&e��&_(��Uf�-���߲�.n���;�~q�����ӻn�lP�]tO�k���ji/0̄:7�����O]��|[��O�;w[P"�tG�n�])^3:�{�٦�J5��y�����Cm����]g.�w���
������<��{Dɋǥi�_�����(=ҽs2�r�o����QFOw�װ�Z�:������?�K�����(������?Dj��A��X�c*��O�R�u�$+&��1)�w����R*�{͂g,������șf@�l������F� �D��p~V�ĕ�/V��u����7���PHam`�E�v��?l�`�'pQ^Z��2`%�_7L��.Tڰ��疡�K��/N���_$�<��1��	x�[��2�8�|����@H�8˅�p�Mw�"��LP�i�@z�S\��a� ׄ4�K����l�uL�����ފ0u�tM2�Wm����@���Tm��tZ[��i95�ĊL�Q؆�YaR��R,t�a���S^	�?MU�nѺe,5-<_4q&�/��x�eM3��҂�מ��!jF���u;�6��Z=M��^�� �t�.��񾃰;Y#$��Q��Ө��:�hLB��p"<p��P�Ju����{��,<�^Nb,gP�S�5s���@����5-M�Ë��s�?���G����j�_�?�	 Zh8:��m�V5@�L�1.ND�tt]՛à����,��>}�|d�~{�i�N!е@��3Fm��D�<���m����KBR�kRZ`wq}�6��ެ�����	��^�OJ�i��ra�r�]�Z{�4rP�m�5;������b��@#�k4Jnh��$�sQh����������f1����x?&�ve>�v`��<��c�����92���U����2t�O;$п�0}3�C�%���Zbr��j�B��������(�9(G��AiH�A��*-`P��,�~�����	~ ����:y��YR����u��d�<oƆ�K̄{��T�Nq�P�xϨ8������˗Cı�}D�k^�,@Y�x�R��tdA��:Zm�_+L���D�7�/���c1NX��ˀ����	�?�{�c����������p�����jg�Ӂ�h&hzD3�e���3a����$𢁕��3�|i�V���/��S��Ae��4!����)v%�0�X�@�� ,Q]9t��ܬ�,�SgG�R9�_|~y=Ԛ=�w�pt�/��n9R�{j�_���`���w��A������%��>���%��M~��T9����je:�#h�x�%��Bx��ֳM)��Kn�Zh��?��B�����\���۷`}b���&���"���TV�@k��N��L��AxI�R����O�4t�CG�nœO�k6�p�-O��"�+�æ����w�w��`��'������9����W������Ԫ��[ܯd����D����x��yu�0���¼� �q���_��>0L���iߧ8O��<7n�ť��w)p���<�T���� U��i «CC��������չ0L��1�i�:�~�;�Ÿ���e���&�B�`���?y.��F���_�v��0��C{4�������f�n��7- �4��k���D;�׭0CL�� �=�I���G!�1r)����C��P��n��'��0�r˱i��Ҿ�$,�c�-u 9d���yJ���2�N��B��[� �K!��݀3f�VȄE�o ��
��!)1O����=S�V-V����	��=�<�1�1P=]�uF��!�9����;c��t�[m��
6�����[�ۮ��\
�������o���F�U�o)�����+Y5���8�6ݵ��b$|�kafp����f<���E7����<|�	[A��]
x���T��(�zm�����/r)d��G!����Q�V�?�����������'XMAJ�=o��r՚��C�CXq�č����q�$|������So����
���6e�`�#��t]����y��k�=�[�W� 8trm��� U�_����^��!�'��7���nD1XM�rOB>M%ݱ��fÞт��|���Y^�QB��gc��/r�Icz�a�O��j"o��i��������O ���@��t��:�z���N���f��^��GR>������
�Q��v�9��-�$d��Ⱦ�����`ń=ƞ"��R�H]�sLz�c�@�퍱��{{e�;+�o�0�3�9(��J�l7s�}�J�A�k�8i�M�R�	u�
�#���.������5~�����6.�@Dx^��ơx�����f��ll&PCk�JB�(�K��:䔨�)�ߌ�D��C���(�Ϭ6�ʔ*K��R�:��ӐB$3�E,�j�wMo� ��ɲB�YR�J�W�P�I3��!��P�~��T�´�1V�=0�㙧���;�1�L�9J	��x�C�W5��c,ix�gV�������`�Ќ�]cw��
����w	p��_�P��ı�V�W��R���.�Lm���l�x0��W�>�'|S͘��%���gw��?�P���ظ����K�E��a�w��D~��>Q�n�M ]mt���_l˒^ e:m�.u�Qe��� �
�"���?:9M^Ӧ�>5 4br߮צ����5����E��cɮ��/d�g� {/6<��xֳ�g�d�D�b���i/6P/6z���ѿu����)�no��|���_�w��"�.Oa�r^d�g���IqaL��$)������}˜1�����}�?�����W�ߏ�??���5NE!��Px��Qk��f"k��(�!y$��D-(&�D���7%��)Ik��-��o�q�k�ڿ0+w��`Ed�Y���K���=�~�aR�n��:��\�fm��ӿ��o����(���o�tX���?Zk���w���3������7����&6^Mk��c����8%DNp��Ώ���x��#����j�w��� p��ǯ�^
|���n���1g�����c�����G��
��15�:N�-�������6���B��7���i��Tv�#K�e���S���c�E�}�
է���1��d&�/=�g�)������B>�ʝ�R��jʽ|Rn�Kr��׏����H2�7��U#��{��I~�8�_�s��S�2{�����|5�lRGG��̕\J6�G�T%�.�j9�S��v�q�2{.W�<��>�yj2�NW:Y�DЮN���\E~�b�L.�?��8�oZ�ڛ�uZ��kw�����S�d�b띾י���i)�BE���B����+yᘤ��4n��N?>O�
�V/ux�>:<�ez���W�Jwi]*Y�=�<>�P:R���9.$ݖ_�����u���ɱt��kW�F!�Q��;><.��X�q_腲��\�Vr��^�xQ�$OqO&�d�C�\r3�K���̎���d��ܽL��e�R82�.��7����d�Ҹ�K���}�}|�J��	ܕw��^VU�?��v{��b9��
��R�T��s���y���+�"�m=��$#�C2�;ʹ\ }�S*$��fF>��B�"���{��BjW�';�)t��|2�N7K{��n�C��% ��M.��Tᵴ�g�S��exS2ה�j*�����;=�i~�UN��	��q"��O���y	���j�(q��G��fYڍ���~���.��{�D�)���v ��Sb"~Q/VK��;�N�L1=A����p$�y�Л{��~�5&��ӽ~��ݻA�.��}��={����0�Yx��������kw�<���۾�%���?:�������r �'y��n愦>f
��ޓ�Y{t2�� ѡ�����%w5�P۵�c�t_>���T�kڅ�M#媴{�N�\)Y.�)�Z,u��U��ϯ��NJ3��P�1#���Òԗ���G;BNm�Z�z�0�ʾ��ȑt���w*�d�eR��ٰ���_,j����=��9�ϋB|���$q%�K�v����,j%1�I̢6����,j!1�H̢���y�,j1�G�$ۈ�j}EP��O�i�I+�o���?������G_��'L���+�o���ɽ|*h�e۽L�d���R���C%}ؔ30�33�tV����M'b��u�:�ǌ��=���8��7�Q��h�lu��ݽ����]>��{�ڻ�;]�Y�ô���p�}�^���'��&U�;��:��̽�?r�C\���r�	HݾI������Y�@��Y��輨��'��A�Mh��٣��k�����?�x1t�����	�}�i� Ҩ��*=1k4ȩ��U>Ё:l���ީU�u���}�������'��
�v鏠k  mt��o���Z�~�u�l��:�e���@ҋ��4�G����FC6�{ n(+�߆�ò�_�����O�A{o=������Nj�6���M~d����`��:�dA�Q�-�Ե�KBH�5�}:
]��n��E$8���tr������c�y��q ��z����c���
��m�F��G�6�< u M�I�$�e�*�0���i}R�E�m��v� x��Ꞽ=���&�u$���ah<��Ã]L3�fz�K��7���c'q:ί��C�;�;N���8���!��#���� n �!�����
����!n���?q�����-㧗N�U_U}��U�W�mqI>h��3N/>"��~�w
e���������A���83�.m<�b���p[��r��^���Mh�Lu_� �|P�\��]"���a⎎�	�pcW>����#��O�<��\J~�d�J ^l"k��C�΁1��W(�Ơ>��%9�@�,���	9U�	"��j,�i������M��#wP�%�S.9��v%<�0/�F����0�?�VP�Ct�B��\_#d�gg�d0�$}uw������/д3���x��B�1B�����S58"b�c4�䊱� b�<��%�i�>T݃:�+�n�<9s6�R>�u�T~�5_�V��P�&$�B}�^��Ƒ�Ɗ� 4��<p^7֟Y��%H4��YϽ����?z���rv �S�0D�AA�F3{��JϘY����������i<x�Hw#��ځ�MU�v{�岬n�ˁ� �a���<���i:�^�(Gڐq�;l��m5����d��f(�j�2�'O�Wӓ'0�G&w�N-ǖ�+��
E���zg��PE�v���Q�pw��I���h�jh�b{eW���D<�=�O��/����ؿO���~���?��j���ӿL��~����������������E|Jߣ�%�k{/������~�ϊ��n��W�����N�♸��Hĕt*�R�X<���8�US�TL��d����j2�P4��L�V��K��#�#�~�����?��̧���O�d�T?K���O"ߏߍE~+�����ק(��_���ۻXD��������[�����Y������"�x��iϿ9�a�b����Ց�^�Jru�ɴl��-�I��s�j��`xV���sƮ��1q۽c��wE�����{�|OdMwy!J���32jމ-*+��:�Ϻ �-ݴz�F�Eq�[1%ws�#1Ʊ$6D�w�&�΄���(��G�@lt�<��y��`Zc\ȣʤGW�bc����_����Eyt��)G.�f:k��)h8G���Y��ܝ��İNS��e�C�@X���H)����w��#�w&���+��M�Pm&_-�ۍ��P&�|�2oR��\-4Z)�19 ����9jf#Vc��(����
#���-�ď�t
�G?�spf���r���b&xO������m��-^+�6?��sp>"���30�y]81���x�L���\�l0��[NϢF��f;��D�Xd3Fru��[��6I�,��uVG噖
'F��L�y�ٲLa�a�9%U�pz$LT�'�}1sl5�W���޵���SɗN%���Jد�6�y}&S����Q�R;����'�Ȳg+*U�tcF#7^^T;�OD��)p!���bE ��ET��b�֪�@��v�'�a�=�����S?��N�U-5��ti_�t��KU⶞V�li��m�"+�E�'%F?'bz[H%�-��6C��N�mN��������ϳ��t�d�9&��"��+��I���D�
���C�Ҋ�r���s��)3�y"[���ϦTj�HjI�j�-�ɏ;m-�/�q����Ü����̜3*�!���ѱ�ju[�i�F(�>��~?7�gR#�
.�F����G~a���;���k��+{/�������@l}���%�s�7+��6�V�=�C�|tS�i�e���{_���m��N����k���^��b��Hd����+���\V,�������މ��׉�&W��_��Ǟ����"?���{�{��g׊��
�2�u�`g�U����^V�t�$��{t>�����sL���9z��{N�,�$�c�E��j���%q�9,�Wt�^�D�coK��m����o�B!��Җ��z��ص�Y�A����n7�uvE��Y*�*p���?��T-ў)�U��b��)�X��z)&7�՞5)8���`�L��:�K�.LJ�&�q����R&�u<Vˠ�K$��j}g8��X�A´s�N��l�2��,�t��/��i�s(�K��o��6#t�+��P�Z��p,��~�.����LI��htL�$�$��T��Œr�n��-�G@#D�1�Yu�OE�X$��;���Y)�	�ьN�Bz0�����k�&�e90��RTZ��8+��L�ji�AcuA�O���o�����򶁜_1Ǿ�̍*_?W��N��"�YV��e�.+�	�7�Ҝ�3��;q[~�ٝ�6������Pn�z�f*�O!W���L�-����s�r��,iV9�r��V�уa[��&j{�r	�m�U��4F�,'W�u�ƌ3z�l�V�T�s^����C����8��̻�rNd��e�36Ww��ڣ��4�z-!h��b���A�=8?�s:��4�:��\�$^P�M�Q�fG��LM-t��R�=�Zʄ/5������3�]�/.	2��I�L�X�sE]��L�7^:6���a)F�h)WO��Ҫ���l⿸�'*R$˵"+�Q}2>��3�ʲee ���đ��HL��x�d���G����Xp�2!n��+bm_�L ���ʤ��y_��9��
�Y����Qnr`��f�'j�#�=�S�N�����tfޭ7��W҄�mv*�$k��J�h���A!n�2��NdV�)�(�U(��Qv(�t�ܑ��l�|�r�J5��S�J�h��<8S�E��C��Җ�
K�z3�RZ���ˋ�T��LWbNN��3	�N���<�3LVoE�4���dGdS���u�(�0�R��kg�UΨ�W1S`���v��7�x?d�~5�F�t
с�x�2��|�B��K�=�m��=��]�Ȟ���/?�Vsձ5���D��y�x�23ȲO��ޠ����[����7�>}J���)��&��#��E�y�x�^���1�5�aCW�;���-@7�M��[�<}@�Y�@k����`�L{��A??���x�x�s6Ũ���|-�.oz��(�T�,Պ$#��w=ߧ�V:���ҹ�O+{�K�/�/��b��ً�������X*~���D"���ߋx���i�����'I��i��C���}�;�����rja'Y%UQ!03ڇ�I���`P�"'`
F���7�@D.�k*r�3T����#� <�&�i��-�����>������o�{o8׫��Ȱ�d�,����z�'x�f�,rq��"�kjj�9���9�ш���BW �@M����zWD�t]�7�и�u�<GȀ����� ������1�|�04H�S�An@=S�1�&v�U�.H};_ �3໠o`LB����W��g����`����
9V��B�B�]<s�2s�%�l_`�/��ko5�[e��!O8�4��`��H�~��E-��s8h�F��>��!�X��պ�4��;Ws�����\��c�=(�῏�&pHt�H�*�b����^�0S���S߷�&7����k^`+�d�v`.�Cr3���<�i+�R�AЀEމ}�3h2.�E�&ѵ@�am��{��dÄE^d��T��?9�H��z �6q�o��ƨG�n�w�i��St�`K¾~�1
�u�7_��a�_C�H��e��5�E����'���@��o*��FCk�=��5,�d��sx#�Û�R,��F̡.�h��!�E�c�©�ȓ�Iw��IB��>t������AP�M ��>[�-fN1�M�aI�ɚ��l]\w�m\K)�����L��׍�o �DW����2�}��@7��������%��O����u;��pk@Yܺ�)����M����U�[�p�F������ ��#Lbb�B)��Nx-䐤�M�h!�Yc{j֖��6��0g`���alh� E�l�gv�h6�U;Q�#��?j=n`�A�c���yu;��]��.�����(�pb:��uX"Y�Nu`�n)�&��h-�*`�^��)���հ���l5o�x��#?|S������~�!��~�F�	2M���f����:�FH���##G�OC5�Ss��l0
�����8� v�Y�P&VP�*�8"�P;�AǦ�i��um�i�N?���a6��ג"|8�3��&�����,$	\��xJ[G:����m���f��cN���ش���p�R!=�bT)���3D�]3»�p_o8�/j����.�8���k��'�t|+�G2��2��y��ч���H@�VɎ�K���GP��?6"ϣ̡	���u�aB�4ǜ��H���݋���䎂M�q�7з
A�h,��U���Y^(ߠ����� �WVt�w��@�
�Ǔ)�@N���
�q5��R�^O�SJ�O@�q�?K+r_�gS �Ȩ�N#�����}a���ӼXn�*�0�n�ǵxɇ0_����i/vH�0�P]>H*�TȲKdbi(�&z1� �R����eR5d�q��LVM�U
��
C>���o��s�7���m#5��G�3���7�7^x�S���.*�w�v�ߑ���J܌m��o@�.����O��B�?�ˏU�i�g�_a8��7��cغ�]��m
M���U�1^�&�n��W�/9�vE�rLYl��qhy��(��&�0���
��=���*hu&jN�f�u��5�E5��dLK�j�i�*v0:�2������E2�ѵ�����0��t�p��m��w/���+S.'yT�f���6xD��R8��|c����\�*�*����ǳ��f�c�p��P�����0��s��9�F���g[=���K��O!E^�z��s�%��KK�m㪹#X�XmJ�j%/N+�Ԯ6�Dػ�>���nV��:���L0Յ^c��E�A�e=<W�e�
|�?9FbX��?Ι�ހc�ȟ��rE�������C��0��$�+���z�<����L>��R/aajs�P�It�2���p���8��@����nb���[�|�z�=&��
~��+�D+��zcp�R[��#	$�|�ح��|W�Ķ��qDk"�!�8���(�*���Bё���NQ��m�����Y04ɻ>����]Ys���}ׯ�ީj4��j��@�Q/�4!���?��N:�mǉ�N�{U*�;p`����)����o��D��<�������������i�~���q�{Οan���?X�sԽ�7	��(���|���{�F �����y�	p��"������お������@�/ç*����_�S����ρ�;�8Ѐ�/u���#�C�B�q���CT�/�$��bR$g�QW�`)2
fƑJ�H�1/��	N`�「b�����G�;?7p�������	��߯I����Ŭ6I7y�ٮ��ckO�F�پ޲��2������Y�;�N����9nԭ����� [3�5=q�!ӝ|�v��3��0]Pәߧr�/��p���=]�Q�0_��CJ�i�u��������ﺝ?8�������Ͻ!U?O�c�8������(�����?�����oz�~���������]������o��U��������?%��@�#��4�{k�,z ��W����<�?
���O>���.Qt@��������}�?	��U���Vu��[8
X�?�A�'� �/�!���n���sw�������|h�!����O����߹������O�t�8�嫶Ԋ�l1,���ϲ����R�/���'�3�����e�{��6�I�o��(�ϛY5B?�o��e�X:4�OM\.��Q�틲�:�y�S�t�ˋ�~��L����1�v�l�r��v��Vm�ѰO.�/Nq�?�������>_�>���l��j/dzҢs�8���~Mxm��oY�����3�,g�ݞ�۹O�rX�W�E�L}=�r�,�+����!�%;V͢P��f瘨Fs�
����0��͍(�v?����4v�@'��%�2���%��P��迧QHT��?��Â���_��p�B,���O��F��'���j�������,M���*@���������+�s��(��?�&�?8����_^��\���k�?8ӃS1��O���J{�p;������W�����/a}�GK����x���뵆;��O�l�x<�++������}�!���o'k��l�P����R��;5�glw����M��mKϞ�z�q},[r����3�%˅��/�)����2>�R�k߽���c�e�M�VI&#��Ӣ���M�m��t����A�Ů7�I�r*wg�/���*�H����I��Q�,2$��q�vd�������߀����?
�
`����%˷���
 ����8�?C���s��� '��f%�3��B��"N�V�HN�����@�0���>/�4�$�!�HL@�$��q������!�G�_�����\�Se۫7�6Od�L<J�[�R�9�EÚ쓠�~��wD1r7'�??��8�<I7�uw��]���;�a99��S����F���%Y���6����%�F���pI3?n�gÏZ���V�p���gu����WP��8���U,��*���{����U��8�?���W�G��GS��6�DH\���g�����s�����!����������#5��S��/ߖvv��3e}N�
7U���2!�I�ا�6��˪PZ�cm���_dao��2i��A�q��x��4�+���~���� ��`��:������A��_��ЀU �'���
���������/a�*��q=:g��S�<��������r������3⪶�?��xz�'v ��ه; �R5l�V�B~�T���Ww ��i�e�CS��:��1��^�K�0#z�F]1ۅ�il����jҵ��:�9���&pv���z.$�ޜ�B���z�xaA$��@ߍ�/O�����|�� g�P
K��%��U|����/��Iҋ��i�h�H���+�HQ�']��f6;43KM�'gn)5��QV��(5�����7���;���L�<w���e�ԦS����t����g����e�nGN�E,�cw�\T��W�zk��q���b�����/�A���d�p��@����P����Ї|���_����?(�?P ������G$��~�����?�B������������?Q0�_��?J���  Y�"?��I_�}��Y)H�c���6���H�bV�)��c��0��?������������ei��t=�4��=��Y�vn�Gl���u��K���ׂ�.�{�-م��M�<�[�V�͚Q��t]&]���Nw=��xR�+��g|�ز�CZ���z���K2����8���`�������f�P���P��{��,�������?��!���u
�8���j������!r��o_���� ����;�@�^���C�k��}�nFv�Օ�e;ҭ�\9w��aYI��&�/��:mω����=F�L����M�c�wQ��q?�ǜ��R�xī��ͣh��j.���m;'���Ss��r^������6��x$�����7e��Gn�r��	ޮ�D��̊z}�c�K3)��`�t,�m�Z����~;�V����[Y<�((�"�~gY���n�ơ�w�Rm�VJ��������D���j8*��O�z�Ә�R��R}��j�fp����tR�zb$.g�۵ݾD��V���QX�pt���j�|2���$�"{ؗ�n�F��U���ߊ�F��~w\����8�?M1��Z��?4����G����!�C�7�C�7��A�}���W� ����[����P������K��,�����?
��/����/��V[�0�M��C�������V�<������s�#�O��}�� �� *����B� �����a�wU�����b ��W��ԃ���H���9D� �������_��	��0�@T����<�? �?���?��[8~
X�?�.�������ɐ
����X�?w�����?��T ��G�<�? �?���?����A�U����B@�������ʀ��9j`�?����	����������?�D�_�&��_ �����~o���a�;`�����8����_�������_������G��C��2�d��C�_ �����g�����8�?E]�`@���PR��R<�@%�fb��x1�ɐa�ЧD��J�}�gYN�_�Q���8�?�S�W�o��^�]#��3��K��l]#N��"P�I�-7�8	IE���۴.�ˀ'��<"]j���juZ5�8,������l���?������5\�_j�]��m-��-���]��*憣�Lu>����KǴ�umx�t�ր�ױbͷ��5��{RU������?�C�����o�������:`����S0������5��������!���2�녌ŝkywP4jsG��,V[�^T���٠z��"���%����=�+����ڀ>�F����3��I�>�|#��Թa����Q	�f9���My��[Z��лz\��i��fћ���[�����򿈀��������7 ��/���0��_0��_���Wm�4`�B�]?�����>����_�O����#F�~�N�lq��)s���~��{�v7i�)��5�]�|���x�1�����zM;-�=Ϻ��.H����ǩ�ʢ��'��I�<��ر�s�/�̥���l��v~ǖl�;���jn�^ۍ�/��������[��3l(��\�%���'/d�xuX�K�r��$��n�F��T�ڱR�C	{�e�nf�C3�eKwT�%���^Ҭ�����$`R12r�~�s�����Q�5;KϔS��O"��HkPQ�\�H��m�kM�Z|�3��l�ㄽ��wV�'�{����W�����_�d9�{�R����q��/�~��{�S,�?��Q��O��F����?9�A��@q�?�����?
���4I��Y�@��Ͼ���P��?����X��!�����쁪�����e���n3I��EIJ'���uW�+�W�44�}��P�ۢ��qӮ?�V�"޻��jO)?�{?^R~�ל�S�ɗ�o����-%yI]�o��[���ZB|k[2�%	�dZ�k��R���P�7�3����e����D�3W�.�&���j&�ƴx��Hh��v���%wj�9%�P6���y�Y���b9?l)����s�V|J�=e���K9wu=�BI���kY�{/i?��ׇ�V�R����8��*°3왚��7e��T?�N�>�[W[��9���g���,sb�dM��T���*aۜ���Ʋ7�'�ܓOk�]�\Lm�Zb$J:��Jឧ��_�����)IO�k��2�p,�]m��߼����]�����x��a&R,�K3&����,J��mO��l
,#�|F���8�(?&C*�����}��U�A�����Ofr�ˏF/VI�^t�����_��9�{�1�蹧�_����ʷj�x�\����+>��K�����1��P �G	̽��� ��C�c�8�W��]��@��C����������\<uY�����օ���f�]������E�KC�^pO��[��x_�o�g��3��[�xC�ob)×�_�%����#ޖ�s�4w[�RR��p�U�]�v���p���Ik��I#��j��y�9yY]q��E~�X9g�r�n���صG���޼�Kڏx����\�{W��&�e��+4nGGO�3Y�"u�' ���Ą�@�����������r�ee�a[�X�;��{ϳ95mvdHE~\d�P��-+��cu&\k�ʳՉm ���X{�Wݩ��Ck�ٌql�Or5��!��Q*�6�Q�!�x�-�����W5p���"�zq�w�yY'QMn���k����]��G������T�B�O)�Fj:].�X�(D2���'��uCU)W�J��h�.X�q�P�����J	:�~"Ҹ����W�	��H?��O��O���H)�Cw�*�L_7���X5�h�;мV�����,[Ղ|�l�����g�����w��1$�i �/V{�����x����fx�%���������)�����r���������!!�O_��������Y��Ѧ��5�B��	̝տ��~��è�������>�'v|����i[�� GN�C�ԪΎ��plWW��ڍ���e�ˢ�Rh^F������\!OSW.���ᵄ��R'�]Oz������T/���0�'b7ܛʺ��3)���y��8��D����y��$��$���z8���y�heۓ��S���
��Yz0۶�-!�aᥳ-6:��(���[,5��>K��E�˚�͡E�f�KʦX;�͵�+2k�0y���������z�ʪk�ߓ-���ڴ�ե�X��&��h�	���#\ɐ������ڡ��6kV�dY�IƊ�ٲ�����PT,|U�p��=�-�O��}ßF�~k�o��Ii����^��}�<�?�����H�r�������;@�'�B�'���?迟��?ՀC@.��}�<�?��g�����r�\��W�oq���� ����������A�����<�W�g	�Ҹ������� ��\����gJH������E�	������������
����_0�s ��g��~���?��,�|!��?���Oޘ��O9����i����?���� �������؍�_��HY�?(
��߷������ �#%���"$;�"��� 1�H�� ��� �0��/m�����������9�������������S�?���?��C���7�`�'d��ۄ�����}�\�?y���RA>����B.�����������ȅ��h��Y꿕~B��!���߷�������H	���&p\��2���B�P�
����,�R��u���Ik��V�xE�XcJ4FS�����������������ۗ�qXTh�K�/�XS`[\K�[i�"+��%��	5N�"%���L�>mt��+aU�8�g�/�i��x��(U�����X��[}6����&�c}6*En;*��T��6�/�$�G�R�kJmMz]SBw8i���X��G��VVXի�㽫�����yh���3;d���k�����C������������>�a`�W�~����/;����S�!��~���SC"�Q�*��O��i�g�م�rg����!�W�E�3\mT�w��V�l��pC����#�ץ����v���ۆ1Z�N���PZ-����Q�J�M��ʩ��!�{-������7#d��kʣ����/�\�A�Wf��/����/�����������}��(�i��O���Q�u�f�^`�J�(�mI�����?q�����C�r"7�pO]q��@n�yg򲷍�d�k��I��0�3��ǝU�E/:�3-2e�8L�S#��L��Tt�J,�\a��60�Ol[keᕔ��������RBc�V�m�%�����Jq���I�F��6�>g
"�ӪOe
ь�z�Zr߫����(}>r�rK�WY�|��{)���O�5������S�����$Ml�
�P��o�ͦ:c��[f�P�Y,�A�l|^L���#�IU�h:�h�tj���y��y�8�OY�g���@�GN������v#�#^�) ��ܨ�b���@j������	���?k�'�+�O1�Ȕ��"��/����?s��o��@�O*Ȝ�_L����G ��g������My�p�Li����?�4����G��_�B��7�A������ �) ��o�����2Cn���������_�?R�W�?NI����C���0��.79��?��vU��ӭ��"��\�QO�Ia�}����ڏ�ǐ?S���~ ������ѥ��s���to �����pP�q'\�1;���Ū���e��]r�o,*���`�:��֝�K�Y~��Z�IQx��lP6&��F������I�/�u���_�Fݯ�
��ͱ�i�#C*��"Ä��nY�<�3q�ZV��Nl�]���S���N%Z��f�cC}ʐ�i��&F�h/جF��4⽶���Â^��Q�st�\����iN�e�D5����Qf���t�B���f�\���<�kq������_.���3C����#���\��7���O���_���_���$��d�����I���w	���[���)�?#��ol ?���!�?3|-��V��������mԬ�ڎT���5�R��������H2/����鯵��x)S�� ��?j ��`+V�G��:��e��h(͸����u-Y����ReJ=@9ܻe�zTgA�j��Jh�V��Ζhˊ�5���k �����  I�� �#6곲9i��VE��.��j�\X�D;ud�e�Q�Ġ�w�{���x���ʦ-F�Z��6�����P+
]��jL�^;R-�������_��+d��>L����O@���/�_�o�?����@~�������àM��}Q�T 0�&U�"�����5S�0(MWZ��bA�������ߚ��������s�̙�M:e�9�{�	K�i��|9���ߩ+Q����e��c��N	��7���+��m��;s�^#Ҋ�#�3K����u�T����4��C� 	�Ť�Σ�`>K��-{���|-�����gvȴ�O&����9���C��r�����2���I �00�Kq���C��~d��Mv뉵ծT���T��L�\�����&z3��";�m/�=���v4���U�Fs�k���fcB!^xcj��ƌZ#����vN�R���zؑT�t��v�n�7�:0��$ �{-���_�Q	�ȼ��� 8C�"��2�A��A�����˲�4`6ȃ���迌�5�7I����MK�艳�(QĖ�p�Ŝ���{������j ��D /k �+3�)k����+�6��F���NQ��%��J��SY�%m9/3ᑦShmJ�z�22N��lh^PWkxy^lo;�z�s�ӧ2It��Q����s�ь�z�%}����F"�����[:�����˒��zY�y=`�-����)iW��������(\y?4�����l�S!=�k�-?�E�3�@��CNV�ۯ���'i<3�N��,�:1b�ks~lCÍd��o6����*�*aӢ��d/4�D�R���[�fd/�*�_N0~3�[n���^/������?F����'H�Ɓ����97u���}%�ύ���O�ǣ����~XY�/��yQz�e��wo��*r�.<$�{�|װ�z�~r:g� �?�A��݅�.�֮�*<~x����G5Y��{�-�q��eW��Ǉ��pxx�S��0~b��r�pY��$�/�O�k���-	ŧ5���m���?��?�� �d5��)�o������J`!��
���S0l?���?�o;aAY��7f�8��	������T�P����kd'�v���}���?;G��t��O�g�W�Bh�m��z�����[�����wo����-
�?�/�y��j��Q��������M��/x�"��y��o�~��mG�?�6����Y$!��q�=��6���:�Z�������"9�H������������0u�p~�
�[xz���lGS�ݻ����Ȋ���9�혅uLo��{�ς;��)!�l�~(���h���k�O~��mT��D�,����[���k]���6>�3��o�3e��9>]+x��c��o�/���ŗ��yn�F����b�����ˍꡆZ/zin�|r�u�v�tH�q����C����+���A��EYzj�")`�	i��.����޼��,��}P??��f0y���ǻl�             �9�?];�� � 